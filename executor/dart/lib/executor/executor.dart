import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:core/core/exceptions.dart';
import 'package:ffi/ffi.dart';
import 'package:memory/memory.dart';

import '../executor.dart';
import 'constants.dart';
import 'registry.dart';

final _executors = List<Executor?>.filled(maximumExecutors, null);

@inline
void _awakeExecutor(int id) => _executors[id]!._awake();

typedef ExecutorProcessor = void Function(Pointer<Pointer<executor_completion_event>> completions, int count);

class Executor {
  final _callback = RawReceivePort(Zone.current.bindUnaryCallbackGuarded(_awakeExecutor));
  final ExecutorConfiguration configuration;

  late final Pointer<executor_instance> instance;
  late final int descriptor;
  late final ExecutorTasks tasks;

  late int _id = -1;
  late ExecutorProcessor _processor = _process;
  late final ExecutorConsumerRegistry _consumers;
  late final ExecutorProducerRegistry _producers;
  late final Pointer<Pointer<executor_completion_event>> _completions;
  late final Pointer<executor_scheduler> _scheduler;

  @inline
  int get id => _id;

  @inline
  bool get active => instance.ref.state & executorStateStopped == 0;

  Executor({this.configuration = ExecutorDefaults.executor}) {
    final (scheduler, id) = context().executor().state.register(this);
    _scheduler = scheduler;
    _id = id;
  }

  Future<void> initialize({ExecutorProcessor? processor}) async {
    _processor = processor ?? _processor;
    instance = using((arena) => executor_create(configuration.toNative(arena<executor_configuration>()), _scheduler, _id)).check();
    descriptor = instance.ref.descriptor;
    tasks = ExecutorTasks();
    _completions = instance.ref.completions;
    _consumers = ExecutorConsumerRegistry(instance);
    _producers = ExecutorProducerRegistry(instance);
    _executors[_id] = this;
  }

  Future<void> shutdown() async {
    deactivate();
    _executors[_id] = null;
    _callback.close();
    calloc.free(instance);
  }

  void activate() {
    ExecutorException.checkRing(executor_register_on_scheduler(instance, _callback.sendPort.nativePort));
  }

  void deactivate() {
    ExecutorException.checkRing(executor_unregister_from_scheduler(instance));
  }

  void consumer(ExecutorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends ExecutorProducer>(T provider) => _producers.register(provider);

  @inline
  void _awake() {
    if (instance.ref.state & executorStateStopped == 0) {
      ExecutorException.checkRing(executor_awake_begin(instance), () => executor_awake_complete(instance, 0));
      final count = executor_peek(instance);
      if (count == 0) return;
      _processor(_completions, count);
      executor_awake_complete(instance, count);
    }
  }

  void _process(Pointer<Pointer<executor_completion_event>> completions, int count) {
    for (var index = 0; index < count; index++) {
      Pointer<executor_completion_event> completion = (completions + index).value.cast();
      final data = completion.ref.user_data;
      final result = completion.ref.res;
      if (data > 0) {
        if (result & executorCall != 0) {
          Pointer<executor_task> task = Pointer.fromAddress(data);
          _consumers.call(task);
          continue;
        }
        if (result & executorCallback != 0) {
          Pointer<executor_task> task = Pointer.fromAddress(data);
          _producers.callback(task);
          continue;
        }
        continue;
      }
    }
  }
}
