import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'exception.dart';

class ExecutorProducerExecutor implements ExecutorProducerRegistrat {
  final Map<int, ExecutorMethodExecutor> _methods = {};

  final int _id;
  final Pointer<executor_dart> _pointer;

  ExecutorProducerExecutor(this._id, this._pointer);

  ExecutorMethod register(Pointer<NativeFunction<Void Function(Pointer<executor_message>)>> pointer) {
    final executor = ExecutorMethodExecutor(pointer.address, _id, _pointer);
    _methods[pointer.address] = executor;
    return executor;
  }

  @inline
  void callback(Pointer<executor_message> message) => _methods[message.ref.method]?.callback(message);
}

class ExecutorMethodExecutor implements ExecutorMethod {
  final Map<int, Completer<Pointer<executor_message>>> _calls = {};
  final int _methodId;
  final int _executorId;
  final Pointer<executor_dart> _pointer;

  ExecutorMethodExecutor(
    this._methodId,
    this._executorId,
    this._pointer,
  );

  @override
  Future<Pointer<executor_message>> call(int target, Pointer<executor_message> message) {
    final completer = Completer<Pointer<executor_message>>();
    message.ref.id = message.address;
    message.ref.owner = _executorId;
    message.ref.method = _methodId;
    _calls[message.address] = completer;
    if (executor_dart_call_native(_pointer, target, message) == executorErrorRingFull) {
      _calls.remove(message.address);
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
    return completer.future.then(_onComplete);
  }

  @inline
  void callback(Pointer<executor_message> message) => _calls[message.ref.id]?.complete(message);

  @inline
  Pointer<executor_message> _onComplete(Pointer<executor_message> message) {
    _calls.remove(message.address);
    return message;
  }
}
