import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'constants.dart';
import 'exception.dart';

class ExecutorConsumerExecutor {
  final List<ExecutorCallbackExecutor> _callbacks;

  ExecutorConsumerExecutor(this._callbacks);

  @inline
  void call(Pointer<executor_task> message) => _callbacks[message.ref.method].call(message);
}

class ExecutorCallbackExecutor {
  final Pointer<executor_dart> _executor;
  final FutureOr<void> Function(Pointer<executor_task> notification) _executor;

  ExecutorCallbackExecutor(this._executor, this._executor);

  @inline
  void call(Pointer<executor_task> message) => Future.value(_executor(message)).then((_) => _respond(message));

  @inline
  void _respond(Pointer<executor_task> message) {
    if (executor_dart_callback_to_native(_executor, message) == executorErrorRingFull) {
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
  }
}
