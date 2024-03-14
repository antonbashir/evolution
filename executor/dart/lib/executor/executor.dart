import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'exception.dart';
import 'tasks.dart';
import 'registry.dart';

final _executors = List<Executor>.empty(growable: true);

@inline
void _awakeExecutor(int id) => _executors[id]._awake();

typedef ExecutorProcessor = void Function(Pointer<Pointer<executor_completion_event>> completions, int count);

class Executor {
  final _fromModule = ReceivePort();
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeExecutor));

  late final ExecutorConsumerRegistry _consumers;
  late final ExecutorProducerRegistry _producers;

  late final Pointer<Pointer<executor_completion_event>> _completions;
  late final RawReceivePort _closer;
  late final SendPort _destroyer;

  late final int descriptor;
  late final ExecutorTasks messages;
  late final MemoryModule memory;
  late final Pointer<executor_instance> instance;

  late ExecutorProcessor _processor = _process;

  @inline
  int get id => instance.ref.id;

  @inline
  bool get active => instance.ref.state & executorStateStopped == 0;

  Executor(SendPort toModule) {
    _closer = RawReceivePort(shutdown);
    toModule.send([_fromModule.sendPort, _closer.sendPort]);
  }

  Future<void> initialize({ExecutorProcessor? processor}) async {
    _processor = processor ?? _processor;
    final configuration = await _fromModule.first as List;
    instance = Pointer.fromAddress(configuration[0] as int).cast<executor_instance>();
    _destroyer = configuration[1] as SendPort;
    descriptor = configuration[2] as int;
    _fromModule.close();
    _completions = instance.ref.completions;
    memory = MemoryModule()..initialize();
    messages = ExecutorTasks();
    _consumers = ExecutorConsumerRegistry(instance);
    _producers = ExecutorProducerRegistry(instance);
    while (instance.ref.id >= _executors.length) _executors.add(this);
    _executors[instance.ref.id] = this;
  }

  Future<void> shutdown() async {
    deactivate();
    _executors.remove(instance.ref.id);
    _callback.close();
    memory.destroy();
    calloc.free(instance);
    _closer.close();
    _destroyer.send(null);
  }

  void activate() {
    if (executor_register_scheduler(instance, _callback.sendPort.nativePort) == executorErrorRingFull) {
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
  }

  void deactivate() {
    if (executor_unregister_scheduler(instance) == executorErrorRingFull) {
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
  }

  void consumer(ExecutorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends ExecutorProducer>(T provider) => _producers.register(provider);

  @inline
  void _awake() {
    if (instance.ref.state & executorStateStopped == 0) {
      if (executor_awake_begin(instance) == executorErrorRingFull) {
        executor_awake_complete(instance, 0);
        throw ExecutorException(ExecutorErrors.executorRingFullError);
      }
      final count = executor_peek(instance);
      if (count == 0) return;
      _processor(_completions, count);
      executor_awake_complete(instance, count);
    }
  }

  @inline
  void _process(Pointer<Pointer<executor_completion_event>> completions, int count) {
    for (var index = 0; index < count; index++) {
      Pointer<executor_completion_event> completion = (completions + index).value.cast();
      final data = completion.ref.user_data;
      final result = completion.ref.res;
      if (data > 0) {
        if (result & executorDartCall != 0) {
          Pointer<executor_task> message = Pointer.fromAddress(data);
          _consumers.call(message);
          continue;
        }
        if (result & executorDartCallback != 0) {
          Pointer<executor_task> message = Pointer.fromAddress(data);
          _producers.callback(message);
          continue;
        }
        continue;
      }
    }
  }
}
