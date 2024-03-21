import 'dart:async';
import 'dart:ffi';

import 'bindings.dart';
import 'exception.dart';

class ExecutorConsumerExecutor {
  final List<ExecutorCallbackExecutor> _callbacks;
  
  int get pending => _callbacks.map((callback) => callback._pending).fold(0, (value, element) => value + element);

  ExecutorConsumerExecutor(this._callbacks);

  @inline
  void call(Pointer<executor_task> message) => _callbacks[message.ref.method].call(message);
}

class ExecutorCallbackExecutor {
  final Pointer<executor_instance> _executor;
  final FutureOr<void> Function(Pointer<executor_task> notification) _callback;
  var _pending = 0;

  ExecutorCallbackExecutor(this._executor, this._callback);

  @inline
  void call(Pointer<executor_task> task) {
    _pending++;
    Future.value(_callback(task)).then((_) => _respond(task)).whenComplete(() => _pending--);
  }

  @inline
  void _respond(Pointer<executor_task> task) => ExecutorException.checkRing(executor_callback_to_native(_executor, task));
}
