import 'dart:async';
import 'dart:ffi';

import 'package:core/core.dart';

import 'bindings.dart';
import 'constants.dart';
import 'declaration.dart';
import 'exception.dart';

class MediatorProducerExecutor implements MediatorProducerRegistrat {
  final Map<int, MediatorMethodExecutor> _methods = {};

  final int _id;
  final Pointer<mediator_dart> _pointer;

  MediatorProducerExecutor(this._id, this._pointer);

  MediatorMethod register(Pointer<NativeFunction<Void Function(Pointer<mediator_message>)>> pointer) {
    final executor = MediatorMethodExecutor(pointer.address, _id, _pointer);
    _methods[pointer.address] = executor;
    return executor;
  }

  @inline
  void callback(Pointer<mediator_message> message) => _methods[message.ref.method]?.callback(message);
}

class MediatorMethodExecutor implements MediatorMethod {
  final Map<int, Completer<Pointer<mediator_message>>> _calls = {};
  final int _methodId;
  final int _executorId;
  final Pointer<mediator_dart> _pointer;

  MediatorMethodExecutor(
    this._methodId,
    this._executorId,
    this._pointer,
  );

  @override
  Future<Pointer<mediator_message>> call(int target, Pointer<mediator_message> message) {
    final completer = Completer<Pointer<mediator_message>>();
    message.ref.id = message.address;
    message.ref.owner = _executorId;
    message.ref.method = _methodId;
    _calls[message.address] = completer;
    if (mediator_dart_call_native(_pointer, target, message) == mediatorErrorRingFull) {
      _calls.remove(message.address);
      throw MediatorException(MediatorErrors.mediatorRingFullError);
    }
    return completer.future.then(_onComplete);
  }

  @inline
  void callback(Pointer<mediator_message> message) => _calls[message.ref.id]?.complete(message);

  @inline
  Pointer<mediator_message> _onComplete(Pointer<mediator_message> message) {
    _calls.remove(message.address);
    return message;
  }
}
