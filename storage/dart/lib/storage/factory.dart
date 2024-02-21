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
  late final MemoryObjectPool<Pointer<tarantool_call_request>> _callRequests;

  final _evaluateRequestMessageOffset = sizeOf<tarantool_evaluate_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_evaluate_request> _evaluateRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_evaluate_request>> _evaluateRequests;

  final _spaceRequestMessageOffset = sizeOf<tarantool_space_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_request> _spaceRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_request>> _spaceRequests;

  StorageFactory(MemoryModule memory, this._strings) {
    _callRequestsMemory = memory.structures.register(sizeOf<tarantool_call_request>());
    _evaluateRequestsMemory = memory.structures.register(sizeOf<tarantool_evaluate_request>());
    _spaceRequestsMemory = memory.structures.register(sizeOf<tarantool_space_request>());

    _callRequests = _callRequestsMemory.asObjectPool();
    _evaluateRequests = _evaluateRequestsMemory.asObjectPool();
    _spaceRequests = _spaceRequestsMemory.asObjectPool();
  }

  @inline
  Pointer<interactor_message> prepareCall(String function, Pointer<Uint8> input, int inputSize) {
    final (functionString, functionLength) = _strings.createString(function);
    final request = _callRequests.allocate();
    request.ref.function = functionString;
    request.ref.function_length = functionLength;
    request.ref.input = input;
    request.ref.input_size = inputSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _callRequestMessageOffset);
  }

  @inline
  void releaseCall(Pointer<tarantool_call_request> call) {
    _strings.freeString(call.ref.function, call.ref.function_length);
    _callRequests.release(call);
  }

  @inline
  Pointer<interactor_message> prepareEvaluate(String function, Pointer<Uint8> input, int inputSize) {
    final (expressionString, expressionLength) = _strings.createString(function);
    final request = _evaluateRequests.allocate();
    request.ref.expression = expressionString;
    request.ref.expression_length = expressionLength;
    request.ref.input = input;
    request.ref.input_size = inputSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _evaluateRequestMessageOffset);
  }

  @inline
  void releaseEvaluate(Pointer<tarantool_evaluate_request> call) {
    _strings.freeString(call.ref.expression, call.ref.expression_length);
    _evaluateRequests.release(call);
  }

  @inline
  Pointer<interactor_message> prepareSpace(int spaceId, Pointer<Uint8> tuple, int tupleSize) {
    final request = _spaceRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceRequestMessageOffset);
  }

  @inline
  void releaseSpace(Pointer<tarantool_space_request> call) => _spaceRequests.release(call);
}
