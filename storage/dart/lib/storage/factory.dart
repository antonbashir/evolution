import 'dart:ffi';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';
import 'serialization.dart';

class StorageFactory {
  final StorageStrings _strings;
  late final MemoryStructurePool<tarantool_call_request> _callRequestsMemory;
  late final ObjectPool<Pointer<tarantool_call_request>> _callRequestsObjects;

  StorageFactory(MemoryModule memory, this._strings) {
    _callRequestsMemory = memory.structures.register(sizeOf<tarantool_call_request>());
    _callRequestsObjects = ObjectPool(
      _callRequestsMemory.allocate,
      _callRequestsMemory.free,
      initialCapacity: 1024,
      preallocation: 1024,
      maxExtensionFactor: 1.5,
      shrinkFactor: 1.5,
    );
  }

  Pointer<tarantool_call_request> prepareCall(String function, Pointer<Uint8> input, int inputSize) {
    final (functionString, functionLength) = _strings.createString(function);
    final request = _callRequestsObjects.allocate();
    request.ref.function = functionString;
    request.ref.function_length = functionLength;
    request.ref.input = input.cast();
    request.ref.input_size = inputSize;
    return request;
  }

  @inline
  void releaseCall(Pointer<tarantool_call_request> call) {
    _strings.freeString(call.ref.function, call.ref.function_length);
    _callRequestsObjects.release(call);
  }
}
