import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'messages.dart';
import 'registry.dart';

class Mediator {
  final _fromMediators = ReceivePort();

  late final MediatorConsumerRegistry _consumers;
  late final MediatorProducerRegistry _producers;

  late final Pointer<mediator_dart> _pointer;
  late final Pointer<Pointer<mediator_dart_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;
  late final List<Duration> _delays;

  var _active = false;
  final _done = Completer();

  late final int descriptor;
  late final MediatorMessages messages;
  late final MemoryModule memory;
  bool get active => _active;
  int get id => _pointer.ref.id;

  Mediator(SendPort toMediator) {
    _closer = RawReceivePort((_) async {
      await deactivate();
      memory.destroy();
      mediator_dart_destroy(_pointer);
      calloc.free(_pointer);
      _closer.close();
      _destroyer.send(null);
    });
    toMediator.send([_fromMediators.sendPort, _closer.sendPort]);
  }

  Future<void> initialize() async {
    final configuration = await _fromMediators.first as List;
    _pointer = Pointer.fromAddress(configuration[0] as int).cast<mediator_dart>();
    _destroyer = configuration[1] as SendPort;
    descriptor = configuration[2] as int;
    _fromMediators.close();
    _completions = _pointer.ref.completions;
    memory = MemoryModule(load: false)..initialize();
    messages = MediatorMessages(memory);
    _consumers = MediatorConsumerRegistry(_pointer);
    _producers = MediatorProducerRegistry(_pointer);
  }

  void activate() {
    _active = true;
    _delays = _calculateDelays();
    unawaited(_listen());
  }

  Future<void> deactivate() async {
    if (_active) {
      _active = false;
      await _done.future;
    }
  }

  void consumer(MediatorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends MediatorProducer>(T provider) => _producers.register(provider);

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
    final cqeCount = mediator_dart_peek(_pointer);
    if (cqeCount == 0) return false;
    for (var cqeIndex = 0; cqeIndex < cqeCount; cqeIndex++) {
      Pointer<mediator_completion_event> cqe = (_completions + cqeIndex).value.cast();
      final data = cqe.ref.user_data;
      final result = cqe.ref.res;
      if (data > 0) {
        if (result & mediatorDartCall > 0) {
          Pointer<mediator_message> message = Pointer.fromAddress(data);
          _consumers.call(message);
          continue;
        }
        if (result & mediatorDartCallback > 0) {
          Pointer<mediator_message> message = Pointer.fromAddress(data);
          _producers.callback(message);
          continue;
        }
        continue;
      }
    }
    mediator_dart_cqe_advance(_pointer, cqeCount);
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
}
