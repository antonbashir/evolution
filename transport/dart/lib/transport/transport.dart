import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';
import 'package:memory/memory/configuration.dart';
import 'package:meta/meta.dart';

import 'bindings.dart';
import 'client/factory.dart';
import 'client/registry.dart';
import 'constants.dart';
import 'exception.dart';
import 'file/factory.dart';
import 'file/registry.dart';
import 'payload.dart';
import 'server/factory.dart';
import 'server/registry.dart';
import 'server/responder.dart';
import 'timeout.dart';

class Transport {
  final _fromTransport = ReceivePort();

  late final Pointer<transport> _pointer;
  late final Pointer<io_uring> _ring;
  late final Pointer<Pointer<interactor_completion_event>> _cqes;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;
  late final TransportClientRegistry _clientRegistry;
  late final TransportServerRegistry _serverRegistry;
  late final TransportClientsFactory _clientsFactory;
  late final TransportServersFactory _serversFactory;
  late final TransportFileRegistry _filesRegistry;
  late final TransportFilesFactory _filesFactory;
  late final MemoryModule _memory;
  late final MemoryStaticBuffers _buffers;
  late final TransportTimeoutChecker _timeoutChecker;
  late final TransportPayloadPool _payloadPool;
  late final TransportServerDatagramResponderPool _datagramResponderPool;
  late final List<Duration> _delays;

  var _active = true;
  final _done = Completer();

  bool get active => _active;
  int get id => _pointer.ref.id;
  int get descriptor => _pointer.ref.descriptor;
  TransportServersFactory get servers => _serversFactory;
  TransportClientsFactory get clients => _clientsFactory;
  TransportFilesFactory get files => _filesFactory;

  Transport(SendPort toTransport) {
    _closer = RawReceivePort((gracefulTimeout) async {
      _timeoutChecker.stop();
      await _filesRegistry.close(gracefulTimeout: gracefulTimeout);
      await _clientRegistry.close(gracefulTimeout: gracefulTimeout);
      await _serverRegistry.close(gracefulTimeout: gracefulTimeout);
      _active = false;
      await _done.future;
      transport_destroy(_pointer);
      _closer.close();
      _destroyer.send(null);
      _memory.destroy();
    });
    toTransport.send([_fromTransport.sendPort, _closer.sendPort]);
  }

  Future<void> initialize() async {
    final configuration = await _fromTransport.first as List;
    _pointer = Pointer.fromAddress(configuration[0] as int).cast<transport>();
    _destroyer = configuration[1] as SendPort;
    _fromTransport.close();
    _memory = MemoryModule()..initialize(configuration: MemoryModuleConfiguration.fromNative(_pointer.ref.memory_configuration));
    _buffers = _memory.staticBuffers;
    _pointer.ref.buffers = _buffers.native;
    final result = transport_setup(_pointer);
    if (result != 0) {
      throw TransportInitializationException(TransportMessages.workerError(result));
    }
    _payloadPool = TransportPayloadPool(_memory.staticBuffers.buffersCapacity, _buffers);
    _datagramResponderPool = TransportServerDatagramResponderPool(_memory.staticBuffers.buffersCapacity, _buffers);
    _clientRegistry = TransportClientRegistry();
    _serverRegistry = TransportServerRegistry();
    _serversFactory = TransportServersFactory(
      _serverRegistry,
      _pointer,
      _buffers,
      _payloadPool,
      _datagramResponderPool,
    );
    _clientsFactory = TransportClientsFactory(
      _clientRegistry,
      _pointer,
      _buffers,
      _payloadPool,
    );
    _filesRegistry = TransportFileRegistry();
    _filesFactory = TransportFilesFactory(
      _filesRegistry,
      _pointer,
      _buffers,
      _payloadPool,
    );
    _ring = _pointer.ref.ring;
    _cqes = _pointer.ref.completions.cast();
    _timeoutChecker = TransportTimeoutChecker(
      _pointer,
      Duration(milliseconds: _pointer.ref.timeout_checker_period_millis),
    );
    _delays = _calculateDelays();
    _timeoutChecker.start();
    unawaited(_listen());
  }

  Future<void> _listen() async {
    final baseDelay = _pointer.ref.base_delay_micros;
    final regularDelayDuration = Duration(microseconds: baseDelay);
    var attempt = 0;
    while (_active) {
      attempt++;
      if (_handleCqes()) {
        attempt = 0;
        await Future.delayed(regularDelayDuration);
        continue;
      }
      await Future.delayed(_delays[min(attempt, 31)]);
    }
    _done.complete();
  }

  bool _handleCqes() {
    final cqeCount = transport_peek(_pointer);
    if (cqeCount == 0) return false;
    for (var cqeIndex = 0; cqeIndex < cqeCount; cqeIndex++) {
      final cqe = _cqes[cqeIndex].ref;
      final data = cqe.user_data;
      transport_remove_event(_pointer, data);
      final result = cqe.res;
      var event = data & 0xffff;
      final fd = (data >> 32) & 0xffffffff;
      final bufferId = (data >> 16) & 0xffff;
      if (_pointer.ref.trace) {
        final server = event & transportEventServer != 0;
        final client = event & transportEventClient != 0;
        final parsed = server
            ? TransportEvent.serverEvent(event & ~transportEventServer)
            : client
                ? TransportEvent.clientEvent(event & ~transportEventClient)
                : TransportEvent.fileEvent(event & ~transportEventFile);
        print(TransportMessages.workerTrace(parsed, id, result, data, fd));
      }

      if (event & transportEventClient != 0) {
        event &= ~transportEventClient;
        if (event == transportEventConnect) {
          _clientRegistry.get(fd)?.notifyConnect(fd, result);
          continue;
        }
        _clientRegistry.get(fd)?.notifyData(bufferId, result, event);
        continue;
      }

      if (event & transportEventServer != 0) {
        event &= ~transportEventServer;
        if (event == transportEventRead || event == transportEventWrite) {
          _serverRegistry.getConnection(fd)?.notify(bufferId, result, event);
          continue;
        }
        if (event == transportEventReceiveMessage || event == transportEventSendMessage) {
          _serverRegistry.getServer(fd)?.notifyDatagram(bufferId, result, event);
          continue;
        }
        _serverRegistry.getServer(fd)?.notifyAccept(result);
        continue;
      }

      if (event & transportEventFile != 0) {
        _filesRegistry.get(fd)?.notify(bufferId, result, event & ~transportEventFile);
        continue;
      }
    }
    transport_cqe_advance(_ring, cqeCount);
    return true;
  }

  List<Duration> _calculateDelays() {
    final baseDelay = _pointer.ref.base_delay_micros;
    final delayRandomizationFactor = _pointer.ref.delay_randomization_factor;
    final maxDelay = _pointer.ref.max_delay_micros;
    final random = Random();
    final delays = <Duration>[];
    for (var i = 0; i < 32; i++) {
      final randomization = (delayRandomizationFactor * (random.nextDouble() * 2 - 1) + 1);
      final exponent = min(i, 31);
      final delay = (baseDelay * pow(2.0, exponent) * randomization).toInt();
      delays.add(Duration(microseconds: delay < maxDelay ? delay : maxDelay));
    }
    return delays;
  }

  @visibleForTesting
  MemoryStaticBuffers get buffers => _buffers;
}
