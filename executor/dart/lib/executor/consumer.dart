import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'exception.dart';

class ExecutorConsumerExecutor {
  final List<ExecutorCallbackExecutor> _callbacks;

  ExecutorConsumerExecutor(this._callbacks);

  @inline
  void call(Pointer<executor_task> message) => _callbacks[message.ref.method].call(message);
}

class ExecutorCallbackExecutor {
  final Pointer<executor_instance> _executor;
  final FutureOr<void> Function(Pointer<executor_task> notification) _callback;

  ExecutorCallbackExecutor(this._executor, this._callback);

  @inline
  void call(Pointer<executor_task> message) => Future.value(_callback(message)).then((_) => _respond(message));

  @inline
  void _respond(Pointer<executor_task> message) => ExecutorException.checkRing(executor_callback_to_native(_executor, message));
}
