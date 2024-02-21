import 'dart:ffi';

import 'package:core/core.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'serialization.dart';

class StorageFactory {
  final StorageStrings _strings;

  final _callRequestMessageOffset = sizeOf<tarantool_call_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_call_request> _callRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_call_request>> _callRequestsObjects;

  StorageFactory(MemoryModule memory, this._strings) {
    _callRequestsMemory = memory.structures.register(sizeOf<tarantool_call_request>());
    _callRequestsObjects = MemoryObjectPool(_callRequestsMemory.allocate, _callRequestsMemory.free);
  }

  Pointer<interactor_message> prepareCall(String function, Pointer<Uint8> input, int inputSize) {
    final (functionString, functionLength) = _strings.createString(function);
    final request = _callRequestsObjects.allocate();
    request.ref.function = functionString;
    request.ref.function_length = functionLength;
    request.ref.input = input.cast();
    request.ref.input_size = inputSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _callRequestMessageOffset);
  }

  @inline
  void releaseCall(Pointer<tarantool_call_request> call) {
    _strings.freeString(call.ref.function, call.ref.function_length);
    _callRequestsObjects.release(call);
  }
}
