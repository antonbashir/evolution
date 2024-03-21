import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'declaration.dart';
import 'exception.dart';

class ExecutorProducerImplementation implements ExecutorProducerRegistrat {
  final Map<int, ExecutorMethodImplementation> _methods = {};
  final int _id;
  final Pointer<executor_instance> _executor;

  int get pending => _methods.values.map((method) => method.pending).fold(0, (value, element) => value + element);

  ExecutorProducerImplementation(this._id, this._executor);

  ExecutorMethod register(Pointer<NativeFunction<Void Function(Pointer<executor_task>)>> pointer) {
    final executor = ExecutorMethodImplementation(pointer.address, _id, _executor);
    _methods[pointer.address] = executor;
    return executor;
  }

  @inline
  void callback(Pointer<executor_task> message) => _methods[message.ref.method]?.callback(message);
}

class ExecutorMethodImplementation implements ExecutorMethod {
  final Map<int, Completer<Pointer<executor_task>>> _calls = {};
  final int _methodId;
  final int _executorId;
  final Pointer<executor_instance> _executor;
  int get pending => _calls.length;

  ExecutorMethodImplementation(
    this._methodId,
    this._executorId,
    this._executor,
  );

  @override
  Future<Pointer<executor_task>> call(int target, Pointer<executor_task> message) {
    final completer = Completer<Pointer<executor_task>>();
    message.ref.id = message.address;
    message.ref.owner = _executorId;
    message.ref.method = _methodId;
    _calls[message.address] = completer;
    executor_call_native(_executor, target, message).systemCheck(() => _calls.remove(message.address));
    return completer.future.then(_onComplete);
  }

  @inline
  void callback(Pointer<executor_task> message) => _calls[message.ref.id]?.complete(message);

  @inline
  Pointer<executor_task> _onComplete(Pointer<executor_task> task) {
    _calls.remove(task.address);
    return task;
  }
}
