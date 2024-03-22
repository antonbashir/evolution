import 'dart:ffi';

import 'bindings.dart';
import 'consumer.dart';
import 'declaration.dart';
import 'producer.dart';

class ExecutorConsumerRegistry {
  final _consumers = <ExecutorConsumerExecutor>[];
  final Pointer<executor_instance> _executor;

  int get pending => _consumers.map((consumer) => consumer.pending).fold(0, (value, element) => value + element);

  ExecutorConsumerRegistry(this._executor);

  void register(ExecutorConsumer declaration) {
    final callbacks = <ExecutorCallbackExecutor>[];
    for (var callback in declaration.callbacks()) {
      callbacks.add(ExecutorCallbackExecutor(_executor, callback));
    }
    _consumers.add(ExecutorConsumerExecutor(callbacks));
  }

  @inline
  void call(Pointer<executor_task> message) => _consumers[message.ref.owner].call(message);
}

class ExecutorProducerRegistry {
  final _producers = <ExecutorProducerImplementation>[];
  final Pointer<executor_instance> _pointer;

  int get pending => _producers.map((producer) => producer.pending).fold(0, (value, element) => value + element);

  ExecutorProducerRegistry(this._pointer);

  T register<T extends ExecutorProducer>(T provider) {
    final id = _producers.length;
    final executor = ExecutorProducerImplementation(id, _pointer);
    _producers.add(executor);
    return provider..initialize(executor);
  }

  @inline
  void callback(Pointer<executor_task> message) => _producers[message.ref.owner].callback(message);
}
