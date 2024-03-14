import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import '../executor.dart';
import 'constants.dart';
import 'registry.dart';

final _executors = List<Executor>.empty(growable: true);

@inline
void _awakeExecutor(int id) => _executors[id]._awake();

typedef ExecutorProcessor = void Function(Pointer<Pointer<executor_completion_event>> completions, int count);

class Executor {
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeExecutor));
  final ExecutorConfiguration configuration;

  late final Pointer<executor_instance> instance;
  late final int descriptor;
  late final ExecutorTasks tasks;

  late ExecutorProcessor _processor = _process;
  late final ExecutorConsumerRegistry _consumers;
  late final ExecutorProducerRegistry _producers;
  late final Pointer<Pointer<executor_completion_event>> _completions;
  late final Pointer<executor_scheduler> _scheduler;

  @inline
  int get id => instance.ref.id;

  @inline
  bool get active => instance.ref.state & executorStateStopped == 0;

  Executor({this.configuration = ExecutorDefaults.executor}) {
    _scheduler = context().executor().state.register(this);
  }

  Future<void> initialize({ExecutorProcessor? processor}) async {
    _processor = processor ?? _processor;
    instance = using((arena) => executor_create(configuration.toNative(arena<executor_configuration>()), _scheduler, id));
    descriptor = instance.ref.descriptor;
    tasks = ExecutorTasks();
    _completions = instance.ref.completions;
    _consumers = ExecutorConsumerRegistry(instance);
    _producers = ExecutorProducerRegistry(instance);
    while (instance.ref.id >= _executors.length) _executors.add(this);
    _executors[instance.ref.id] = this;
  }

  Future<void> shutdown() async {
    deactivate();
    _executors.remove(instance.ref.id);
    _callback.close();
    calloc.free(instance);
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
