import 'dart:ffi';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'executor.dart';
import 'registry.dart';
import 'tasks.dart';

class ExecutorBroker {
  final Executor _executor;
  late final ExecutorConsumerRegistry _consumers;
  late final ExecutorProducerRegistry _producers;
  late final ExecutorTasks tasks;

  ExecutorBroker(this._executor);

  int get descriptor => _executor.descriptor;

  Future<void> initialize() async {
    await _executor.initialize(process);
    _consumers = ExecutorConsumerRegistry(_executor.native);
    _producers = ExecutorProducerRegistry(_executor.native);
    tasks = ExecutorTasks();
  }

  Future<void> shutdown() => _executor.shutdown();

  void activate() => _executor.activate();

  void deactivate() => _executor.deactivate();

  void consumer(ExecutorConsumer declaration) => _consumers.register(declaration);

  T producer<T extends ExecutorProducer>(T provider) => _producers.register(provider);

  void process(Pointer<Pointer<executor_completion_event>> completions, int count) {
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
