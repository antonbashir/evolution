import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';

class MediatorConsumerExecutor {
  final List<MediatorCallbackExecutor> _callbacks;

  MediatorConsumerExecutor(this._callbacks);

  @inline
  void call(Pointer<mediator_message> message) => _callbacks[message.ref.method].call(message);
}

class MediatorCallbackExecutor {
  final Pointer<mediator_dart> _mediator;
  final FutureOr<void> Function(Pointer<mediator_message> notification) _executor;

  MediatorCallbackExecutor(this._mediator, this._executor);

  @inline
  void call(Pointer<mediator_message> message) => Future.value(_executor(message)).then((_) => mediator_dart_callback_to_native(_mediator, message));
}
