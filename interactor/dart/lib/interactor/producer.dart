import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'declaration.dart';

class InteractorProducerExecutor implements InteractorProducerRegistrat {
  final Map<int, InteractorMethodExecutor> _methods = {};

  final int _id;
  final Pointer<interactor_dart> _interactorPointer;

  InteractorProducerExecutor(this._id, this._interactorPointer);

  InteractorMethod register(Pointer<NativeFunction<Void Function(Pointer<interactor_message>)>> pointer) {
    final executor = InteractorMethodExecutor(pointer.address, _id, _interactorPointer);
    _methods[pointer.address] = executor;
    return executor;
  }

  @inline
  void callback(Pointer<interactor_message> message) => _methods[message.ref.method]?.callback(message);
}

class InteractorMethodExecutor implements InteractorMethod {
  final Map<int, Completer<Pointer<interactor_message>>> _calls = {};
  final int _methodId;
  final int _executorId;
  final Pointer<interactor_dart> _interactor;

  InteractorMethodExecutor(
    this._methodId,
    this._executorId,
    this._interactor,
  );

  @override
  Future<Pointer<interactor_message>> call(int target, Pointer<interactor_message> message) {
    final completer = Completer<Pointer<interactor_message>>();
    message.ref.id = message.address;
    message.ref.owner = _executorId;
    message.ref.method = _methodId;
    _calls[message.address] = completer;
    interactor_dart_call_native(_interactor, target, message);
    return completer.future.then(_onComplete);
  }

  @inline
  void callback(Pointer<interactor_message> message) => _calls[message.ref.id]?.complete(message);

  @inline
  Pointer<interactor_message> _onComplete(Pointer<interactor_message> message) {
    _calls.remove(message.address);
    return message;
  }
}
