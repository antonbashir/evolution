import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'messages.dart';
import 'registry.dart';

class Mediator {
  final _fromMediators = ReceivePort();
  final wakingStopwatch = Stopwatch();

  late final MediatorConsumerRegistry _consumers;
  late final MediatorProducerRegistry _producers;

  late final Pointer<mediator_dart> _pointer;
  late final Pointer<Pointer<mediator_dart_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;
  late final int _maximumWakingTime;

  late final _callback = NativeCallable<mediator_notify_callbackFunction>.listener(_awake);

  late final int descriptor;
  late final MediatorMessages messages;
  late final MemoryModule memory;

  @inline
  bool get active => _pointer.ref.state & mediatorStateStopped == 0;

  Mediator(SendPort toMediator) {
    _closer = RawReceivePort((_) async {
      deactivate();
      _callback.close();
      memory.destroy();
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
    _maximumWakingTime = _pointer.ref.configuration.maximum_waking_time_millis;
  }

  void activate() {
    mediator_dart_setup(_pointer, _callback.nativeFunction);
  }

  void deactivate() {
    _pointer.ref.state = mediatorStateStopped;
  }

  void consumer(MediatorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends MediatorProducer>(T provider) => _producers.register(provider);

  void _awake() {
    _trace("awake start");
    if (_pointer.ref.state & mediatorStateIdle != 0) {
      final cqeCount = mediator_dart_peek(_pointer);
      if (cqeCount == 0) {
        return;
      }
      _pointer.ref.state = mediatorStateWaking;
      _trace("state = waking");
      _process(cqeCount);
      if (_maximumWakingTime == 0) {
        _trace("submit");
        mediator_dart_submit(_pointer);
        _pointer.ref.state = mediatorStateIdle;
        _trace("state = idle");
        return;
      }
      wakingStopwatch.start();
      while (wakingStopwatch.elapsedMilliseconds < _maximumWakingTime && _pointer.ref.state & mediatorStateStopped == 0) {
        final cqeCount = mediator_dart_peek_wait(_pointer);
        if (cqeCount != 0) _process(cqeCount);
      }
      wakingStopwatch.stop();
      _trace("submit");
      mediator_dart_submit(_pointer);
      _pointer.ref.state = mediatorStateIdle;
      _trace("state = idle");
    }
    _trace("awake end");
  }

  void _process(int cqeCount) {
    _trace("process cqes: $cqeCount");
    for (var cqeIndex = 0; cqeIndex < cqeCount; cqeIndex++) {
      Pointer<mediator_completion_event> cqe = (_completions + cqeIndex).value.cast();
      final data = cqe.ref.user_data;
      final result = cqe.ref.res;
      if (data > 0) {
        if (result & mediatorDartCall != 0) {
          Pointer<mediator_message> message = Pointer.fromAddress(data);
          _consumers.call(message);
          continue;
        }
        if (result & mediatorDartCallback != 0) {
          Pointer<mediator_message> message = Pointer.fromAddress(data);
          _producers.callback(message);
          continue;
        }
        continue;
      }
    }
    mediator_dart_completion_advance(_pointer, cqeCount);
    _trace("process cqes advance: $cqeCount");
  }

  @inline
  void _trace(String message) {
    if (_pointer.ref.configuration.trace) {
      print("${DateTime.now()} [mediator] ${Isolate.current.debugName}: $message");
    }
  }
}
