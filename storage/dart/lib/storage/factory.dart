import 'dart:ffi';

import 'package:core/core.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'strings.dart';

class StorageFactory {
  final StorageStrings _strings;

  late final MemoryObjectPool<Pointer<interactor_message>> _messages;

  final _spaceRequestMessageOffset = sizeOf<tarantool_space_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_space_request>> _spaceRequests;

  final _spaceCountRequestMessageOffset = sizeOf<tarantool_space_count_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_space_count_request>> _spaceCountRequests;

  final _spaceSelectRequestMessageOffset = sizeOf<tarantool_space_select_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_space_select_request>> _spaceSelectRequests;

  final _spaceUpdateRequestMessageOffset = sizeOf<tarantool_space_update_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_space_update_request>> _spaceUpdateRequests;

  final _spaceUpsertRequestMessageOffset = sizeOf<tarantool_space_upsert_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_space_upsert_request>> _spaceUpsertRequests;

  final _spaceIteratorRequestMessageOffset = sizeOf<tarantool_space_iterator_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_space_iterator_request>> _spaceIteratorRequests;

  final _indexRequestMessageOffset = sizeOf<tarantool_index_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_index_request>> _indexRequests;

  final _indexCountRequestMessageOffset = sizeOf<tarantool_index_count_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_index_count_request>> _indexCountRequests;

  final _indexIdRequestMessageOffset = sizeOf<tarantool_index_id_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_index_id_request>> _indexIdRequestRequests;

  final _indexUpdateRequestMessageOffset = sizeOf<tarantool_index_update_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_index_update_request>> _indexUpdateRequests;

  final _indexIteratorRequestMessageOffset = sizeOf<tarantool_index_iterator_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_index_iterator_request>> _indexIteratorRequests;

  final _callRequestMessageOffset = sizeOf<tarantool_call_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_call_request>> _callRequests;

  final _evaluateRequestMessageOffset = sizeOf<tarantool_evaluate_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_evaluate_request>> _evaluateRequests;

  final _indexSelectRequestMessageOffset = sizeOf<tarantool_index_select_request>() - interactorMessageSize;
  late final MemoryObjectPool<Pointer<tarantool_index_select_request>> _indexSelectRequests;

  StorageFactory(MemoryModule memory, this._strings) {
    _messages = memory.structures.register<interactor_message>(sizeOf<interactor_message>()).asObjectPool();
    _spaceRequests = memory.structures.register<tarantool_space_request>(sizeOf<tarantool_space_request>()).asObjectPool();
    _spaceCountRequests = memory.structures.register<tarantool_space_count_request>(sizeOf<tarantool_space_count_request>()).asObjectPool();
    _spaceSelectRequests = memory.structures.register<tarantool_space_select_request>(sizeOf<tarantool_space_select_request>()).asObjectPool();
    _spaceUpdateRequests = memory.structures.register<tarantool_space_update_request>(sizeOf<tarantool_space_update_request>()).asObjectPool();
    _spaceUpsertRequests = memory.structures.register<tarantool_space_upsert_request>(sizeOf<tarantool_space_upsert_request>()).asObjectPool();
    _spaceIteratorRequests = memory.structures.register<tarantool_space_iterator_request>(sizeOf<tarantool_space_iterator_request>()).asObjectPool();
    _indexRequests = memory.structures.register<tarantool_index_request>(sizeOf<tarantool_index_request>()).asObjectPool();
    _indexCountRequests = memory.structures.register<tarantool_index_count_request>(sizeOf<tarantool_index_count_request>()).asObjectPool();
    _indexIdRequestRequests = memory.structures.register<tarantool_index_id_request>(sizeOf<tarantool_index_id_request>()).asObjectPool();
    _indexUpdateRequests = memory.structures.register<tarantool_index_update_request>(sizeOf<tarantool_index_update_request>()).asObjectPool();
    _indexIteratorRequests = memory.structures.register<tarantool_index_iterator_request>(sizeOf<tarantool_index_iterator_request>()).asObjectPool();
    _callRequests = memory.structures.register<tarantool_call_request>(sizeOf<tarantool_call_request>()).asObjectPool();
    _evaluateRequests = memory.structures.register<tarantool_evaluate_request>(sizeOf<tarantool_evaluate_request>()).asObjectPool();
    _indexSelectRequests = memory.structures.register<tarantool_index_select_request>(sizeOf<tarantool_index_select_request>()).asObjectPool();
  }

  @inline
  Pointer<interactor_message> createMessage(Pointer<Void> input) {
    final message = _messages.allocate();
    message.ref.input = input;
    return message;
  }

  @inline
  void releaseMessage(Pointer<interactor_message> message) => _messages.release(message);

  @inline
  Pointer<interactor_message> createSpace(int spaceId, Pointer<Uint8> tuple, int tupleSize) {
    final request = _spaceRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceRequestMessageOffset);
  }

  @inline
  void releaseSpace(Pointer<tarantool_space_request> request) => _spaceRequests.release(request);

  @inline
  Pointer<interactor_message> createSpaceCount(int spaceId, int iteratorType, Pointer<Uint8> key, int keySize) {
    final request = _spaceCountRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceCountRequestMessageOffset);
  }

  @inline
  void releaseSpaceCount(Pointer<tarantool_space_count_request> request) => _spaceCountRequests.release(request);

  @inline
  Pointer<interactor_message> createSpaceSelect(int spaceId, int iteratorType, Pointer<Uint8> key, int keySize, int offset, int limit) {
    final request = _spaceSelectRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.offset = offset;
    request.ref.limit = limit;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceSelectRequestMessageOffset);
  }

  @inline
  void releaseSpaceSelect(Pointer<tarantool_space_select_request> request) => _spaceSelectRequests.release(request);

  @inline
  Pointer<interactor_message> createSpaceUpdate(int spaceId, Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = _spaceUpdateRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.operations = operations;
    request.ref.operations_size = operationsSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceUpdateRequestMessageOffset);
  }

  @inline
  void releaseSpaceUpdate(Pointer<tarantool_space_update_request> request) => _spaceUpdateRequests.release(request);

  @inline
  Pointer<interactor_message> createSpaceUpsert(int spaceId, Pointer<Uint8> tuple, int tupleSize, Pointer<Uint8> operations, int operationsSize) {
    final request = _spaceUpsertRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.operations = operations;
    request.ref.operations_size = operationsSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceUpsertRequestMessageOffset);
  }

  @inline
  void releaseSpaceUpsert(Pointer<tarantool_space_upsert_request> request) => _spaceUpsertRequests.release(request);

  @inline
  Pointer<interactor_message> createSpaceIterator(int spaceId, int type, Pointer<Uint8> key, int keySize) {
    final request = _spaceIteratorRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.type = type;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceIteratorRequestMessageOffset);
  }

  @inline
  void releaseSpaceIterator(Pointer<tarantool_space_iterator_request> request) => _spaceIteratorRequests.release(request);

  @inline
  Pointer<interactor_message> createIndex(int spaceId, int indexId, Pointer<Uint8> tuple, int tupleSize) {
    final request = _indexRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexRequestMessageOffset);
  }

  @inline
  void releaseIndex(Pointer<tarantool_index_request> request) => _indexRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexCount(int spaceId, int indexId, Pointer<Uint8> key, int keySize) {
    final request = _indexCountRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexCountRequestMessageOffset);
  }

  @inline
  void releaseIndexCount(Pointer<tarantool_index_count_request> request) => _indexCountRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexId(int spaceId, String name) {
    final (nameString, nameLength) = _strings.allocate(name);
    final request = _indexIdRequestRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.name = nameString;
    request.ref.name_length = nameLength;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexIdRequestMessageOffset);
  }

  @inline
  void releaseIndexId(Pointer<tarantool_index_id_request> request) {
    _strings.free(request.ref.name, request.ref.name_length);
    _indexIdRequestRequests.release(request);
  }

  @inline
  Pointer<interactor_message> createIndexUpdate(int spaceId, int indexId, Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = _indexUpdateRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexUpdateRequestMessageOffset);
  }

  @inline
  void releaseIndexUpdate(Pointer<tarantool_index_update_request> request) => _indexUpdateRequests.release(request);

  @inline
  Pointer<interactor_message> createCall(String function, Pointer<Uint8> input, int inputSize) {
    final (functionString, functionLength) = _strings.allocate(function);
    final request = _callRequests.allocate();
    request.ref.function = functionString;
    request.ref.function_length = functionLength;
    request.ref.input = input;
    request.ref.input_size = inputSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _callRequestMessageOffset);
  }

  @inline
  void releaseCall(Pointer<tarantool_call_request> request) {
    _strings.free(request.ref.function, request.ref.function_length);
    _callRequests.release(request);
  }

  @inline
  Pointer<interactor_message> createEvaluate(String expression, Pointer<Uint8> input, int inputSize) {
    final (expressionString, expressionLength) = _strings.allocate(expression);
    final request = _evaluateRequests.allocate();
    request.ref.expression = expressionString;
    request.ref.expression_length = expressionLength;
    request.ref.input = input;
    request.ref.input_size = inputSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _evaluateRequestMessageOffset);
  }

  @inline
  void releaseEvaluate(Pointer<tarantool_evaluate_request> request) {
    _strings.free(request.ref.expression, request.ref.expression_length);
    _evaluateRequests.release(request);
  }

  @inline
  Pointer<interactor_message> createIndexIterator(int spaceId, int indexId, int type, Pointer<Uint8> key, int keySize) {
    final request = _indexIteratorRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.type = type;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexIteratorRequestMessageOffset);
  }

  @inline
  void releaseIndexIterator(Pointer<tarantool_index_iterator_request> request) => _indexIteratorRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexSelect(int spaceId, int indexId, int type, Pointer<Uint8> key, int keySize, int offset, int limit) {
    final request = _indexSelectRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.iterator_type = type;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.offset = offset;
    request.ref.limit = limit;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexSelectRequestMessageOffset);
  }

  @inline
  void releaseIndexSelect(Pointer<tarantool_index_select_request> request) => _indexSelectRequests.release(request);
}
