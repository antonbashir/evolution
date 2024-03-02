import 'dart:ffi';

import 'package:core/core/constants.dart';

import 'bindings.dart';
import 'consumer.dart';
import 'declaration.dart';
import 'producer.dart';

class MediatorConsumerRegistry {
  final _consumers = <MediatorConsumerExecutor>[];

  final Pointer<mediator_dart> _mediator;

  MediatorConsumerRegistry(this._mediator);

  void register(MediatorConsumer declaration) {
    final callbacks = <MediatorCallbackExecutor>[];
    for (var callback in declaration.callbacks()) {
      callbacks.add(MediatorCallbackExecutor(_mediator, callback));
    }
    _consumers.add(MediatorConsumerExecutor(callbacks));
  }

  @inline
  void call(Pointer<mediator_message> message) => _consumers[message.ref.owner].call(message);
}

class MediatorProducerRegistry {
  final _producers = <MediatorProducerExecutor>[];

  final Pointer<mediator_dart> _mediator;

  MediatorProducerRegistry(this._mediator);

  T register<T extends MediatorProducer>(T provider) {
    final id = _producers.length;
    final executor = MediatorProducerExecutor(id, _mediator);
    _producers.add(executor);
    return provider..initialize(executor);
  }

  @inline
  void callback(Pointer<mediator_message> message) => _producers[message.ref.owner].callback(message);
}
