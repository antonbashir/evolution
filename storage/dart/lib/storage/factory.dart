import 'dart:ffi';

import 'package:core/core.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'strings.dart';

class StorageFactory {
  final StorageStrings _strings;

  final _spaceRequestMessageOffset = sizeOf<tarantool_space_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_request> _spaceRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_request>> _spaceRequests;

  final _spaceCountRequestMessageOffset = sizeOf<tarantool_space_count_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_count_request> _spaceCountRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_count_request>> _spaceCountRequests;

  final _spaceSelectRequestMessageOffset = sizeOf<tarantool_space_select_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_select_request> _spaceSelectRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_select_request>> _spaceSelectRequests;

  final _spaceUpdateRequestMessageOffset = sizeOf<tarantool_space_update_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_update_request> _spaceUpdateRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_update_request>> _spaceUpdateRequests;

  final _spaceUpsertRequestMessageOffset = sizeOf<tarantool_space_upsert_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_upsert_request> _spaceUpsertRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_upsert_request>> _spaceUpsertRequests;

  final _spaceIteratorRequestMessageOffset = sizeOf<tarantool_space_iterator_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_space_iterator_request> _spaceIteratorRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_space_iterator_request>> _spaceIteratorRequests;

  final _indexRequestMessageOffset = sizeOf<tarantool_index_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_index_request> _indexRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_index_request>> _indexRequests;

  final _indexCountRequestMessageOffset = sizeOf<tarantool_index_count_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_index_count_request> _indexCountRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_index_count_request>> _indexCountRequests;

  final _indexIdRequestMessageOffset = sizeOf<tarantool_index_id_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_index_id_request> _indexIdRequestRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_index_id_request>> _indexIdRequestCountRequests;

  final _indexUpdateRequestMessageOffset = sizeOf<tarantool_index_update_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_index_update_request> _indexUpdateRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_index_update_request>> _indexUpdateRequests;

  final _indexIteratorRequestMessageOffset = sizeOf<tarantool_index_update_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_index_update_request> _indexIteratorRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_index_update_request>> _indexIteratorRequests;

  final _callRequestMessageOffset = sizeOf<tarantool_call_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_call_request> _callRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_call_request>> _callRequests;

  final _evaluateRequestMessageOffset = sizeOf<tarantool_evaluate_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_evaluate_request> _evaluateRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_evaluate_request>> _evaluateRequests;

  final _indexSelectRequestMessageOffset = sizeOf<tarantool_index_select_request>() - interactorMessageSize;
  late final MemoryStructurePool<tarantool_index_select_request> _indexSelectRequestsMemory;
  late final MemoryObjectPool<Pointer<tarantool_index_select_request>> _indexSelectRequests;

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
  Pointer<interactor_message> prepareEvaluate(String expression, Pointer<Uint8> input, int inputSize) {
    final (expressionString, expressionLength) = _strings.createString(expression);
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
