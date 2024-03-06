import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'exception.dart';
import 'messages.dart';
import 'registry.dart';

final _executors = List<Executor>.empty(growable: true);

@inline
void _awakeExecutor(int id) => _executors[id]._awake();

typedef ExecutorProcessor = void Function(Pointer<Pointer<executor_dart_completion_event>> completions, int count);

class Executor {
  final _fromModule = ReceivePort();
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeExecutor));

  late final ExecutorConsumerRegistry _consumers;
  late final ExecutorProducerRegistry _producers;

  late final Pointer<Pointer<executor_dart_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;

  late final int descriptor;
  late final ExecutorMessages messages;
  late final MemoryModule memory;
  late final Pointer<executor_dart> pointer;

  late ExecutorProcessor _processor = _process;

  @inline
  int get id => pointer.ref.id;

  @inline
  bool get active => pointer.ref.state & executorStateStopped == 0;

  Executor(SendPort toModule) {
    _closer = RawReceivePort(shutdown);
    toModule.send([_fromModule.sendPort, _closer.sendPort]);
  }

  Future<void> initialize({ExecutorProcessor? processor}) async {
    _processor = processor ?? _processor;
    final configuration = await _fromModule.first as List;
    pointer = Pointer.fromAddress(configuration[0] as int).cast<executor_dart>();
    _destroyer = configuration[1] as SendPort;
    descriptor = configuration[2] as int;
    _fromModule.close();
    _completions = pointer.ref.completions;
    memory = MemoryModule(load: false)..initialize();
    messages = ExecutorMessages(memory);
    _consumers = ExecutorConsumerRegistry(pointer);
    _producers = ExecutorProducerRegistry(pointer);
    while (pointer.ref.id >= _executors.length) _executors.add(this);
    _executors[pointer.ref.id] = this;
  }

  Future<void> shutdown() async {
    deactivate();
    _executors.remove(pointer.ref.id);
    _callback.close();
    memory.destroy();
    calloc.free(pointer);
    _closer.close();
    _destroyer.send(null);
  }

  void activate() {
    if (executor_dart_register(pointer, _callback.sendPort.nativePort) == executorErrorRingFull) {
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
  }

  void deactivate() {
    if (executor_dart_unregister(pointer) == executorErrorRingFull) {
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
  }

  void consumer(ExecutorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends ExecutorProducer>(T provider) => _producers.register(provider);

  @inline
  void _awake() {
    if (pointer.ref.state & executorStateStopped == 0) {
      if (executor_dart_awake(pointer) == executorErrorRingFull) {
        executor_dart_sleep(pointer, 0);
        throw ExecutorException(ExecutorErrors.executorRingFullError);
      }
      final count = executor_dart_peek(pointer);
      if (count == 0) return;
      _processor(_completions, count);
      executor_dart_sleep(pointer, count);
    }
  }

  @inline
  void _process(Pointer<Pointer<executor_dart_completion_event>> completions, int count) {
    for (var index = 0; index < count; index++) {
      Pointer<executor_completion_event> completion = (completions + index).value.cast();
      final data = completion.ref.user_data;
      final result = completion.ref.res;
      if (data > 0) {
        if (result & executorDartCall != 0) {
          Pointer<executor_message> message = Pointer.fromAddress(data);
          _consumers.call(message);
          continue;
        }
        if (result & executorDartCallback != 0) {
          Pointer<executor_message> message = Pointer.fromAddress(data);
          _producers.callback(message);
          continue;
        }
        continue;
      }
    }
  }
}
