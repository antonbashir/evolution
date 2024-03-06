import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:executor/executor.dart';
import 'package:memory/memory.dart';
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
  late final Executor _executor;
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

  var _active = true;

  bool get active => _active;
  int get id => _pointer.ref.id;
  int get descriptor => _executor.descriptor;
  TransportServersFactory get servers => _serversFactory;
  TransportClientsFactory get clients => _clientsFactory;
  TransportFilesFactory get files => _filesFactory;

  Transport(SendPort toModule) {
    _closer = RawReceivePort((gracefulTimeout) async {
      _timeoutChecker.stop();
      await _filesRegistry.close(gracefulTimeout: gracefulTimeout);
      await _clientRegistry.close(gracefulTimeout: gracefulTimeout);
      await _serverRegistry.close(gracefulTimeout: gracefulTimeout);
      _active = false;
      await _executor.shutdown();
      transport_destroy(_pointer);
      _closer.close();
      _destroyer.send(null);
      _memory.destroy();
    });
    toModule.send([_fromTransport.sendPort, _closer.sendPort]);
  }

  Future<void> initialize() async {
    final configuration = await _fromTransport.first as List;
    _pointer = Pointer.fromAddress(configuration[0] as int).cast<transport>();
    _destroyer = configuration[1] as SendPort;
    _executor = Executor(configuration[2] as SendPort);
    _fromTransport.close();
    await _executor.initialize(processor: _process);
    _memory = MemoryModule(load: false);
    _memory.initialize(configuration: MemoryModuleConfiguration.fromNativeValue(_pointer.ref.configuration.memory_configuration));
    _buffers = _memory.staticBuffers;
    _pointer.ref.buffers = _buffers.native;
    final result = transport_setup(_pointer, _executor.pointer);
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
    _timeoutChecker = TransportTimeoutChecker(
      _pointer,
      Duration(milliseconds: _pointer.ref.configuration.timeout_checker_period_millis),
    );
    _timeoutChecker.start();
    _executor.activate();
  }

  @inline
  void _process(Pointer<Pointer<executor_dart_completion_event>> completions, int count) {
    for (var index = 0; index < count; index++) {
      Pointer<executor_completion_event> completion = (completions + index).value.cast();
      final data = completion.ref.user_data;
      transport_remove_event(_pointer, data);
      final result = completion.ref.res;
      var event = data & 0xffff;
      final fd = (data >> 32) & 0xffffffff;
      final bufferId = (data >> 16) & 0xffff;
      if (_pointer.ref.configuration.trace) {
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
  }

  @visibleForTesting
  MemoryStaticBuffers get buffers => _buffers;
}
