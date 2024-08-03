import 'dart:ffi';

import 'bindings.dart';
import 'strings.dart';

class StorageFactory {
  final StorageStrings _strings;

  late final MemoryObjects<Pointer<executor_task>> _messages;

  final _spaceMessageOffset = sizeOf<storage_space_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_space_request>> _spaceRequests;

  final _spaceCountMessageOffset = sizeOf<storage_space_count_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_space_count_request>> _spaceCountRequests;

  final _spaceSelectMessageOffset = sizeOf<storage_space_select_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_space_select_request>> _spaceSelectRequests;

  final _spaceUpdateMessageOffset = sizeOf<storage_space_update_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_space_update_request>> _spaceUpdateRequests;

  final _spaceUpsertMessageOffset = sizeOf<storage_space_upsert_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_space_upsert_request>> _spaceUpsertRequests;

  final _spaceIteratorMessageOffset = sizeOf<storage_space_iterator_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_space_iterator_request>> _spaceIteratorRequests;

  final _indexMessageOffset = sizeOf<storage_index_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_request>> _indexRequests;

  final _indexCountMessageOffset = sizeOf<storage_index_count_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_count_request>> _indexCountRequests;

  final _indexIdByNameMessageOffset = sizeOf<storage_index_id_by_name_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_id_by_name_request>> _indexIdByNameRequests;

  final _indexUpdateMessageOffset = sizeOf<storage_index_update_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_update_request>> _indexUpdateRequests;

  final _indexIteratorMessageOffset = sizeOf<storage_index_iterator_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_iterator_request>> _indexIteratorRequests;

  final _callMessageOffset = sizeOf<storage_call_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_call_request>> _callRequests;

  final _evaluateMessageOffset = sizeOf<storage_evaluate_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_evaluate_request>> _evaluateRequests;

  final _indexSelectMessageOffset = sizeOf<storage_index_select_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_select_request>> _indexSelectRequests;

  final _indexIdMessageOffset = sizeOf<storage_index_id_request>() - executorMessageSize;
  late final MemoryObjects<Pointer<storage_index_id_request>> _indexIdRequests;

  StorageFactory(this._strings) {
    MemoryStructurePools pools = context().structures();
    _messages = pools.register<executor_task>(sizeOf<executor_task>()).asObjectPool();
    _spaceRequests = pools.register<storage_space_request>(sizeOf<storage_space_request>()).asObjectPool();
    _spaceCountRequests = pools.register<storage_space_count_request>(sizeOf<storage_space_count_request>()).asObjectPool();
    _spaceSelectRequests = pools.register<storage_space_select_request>(sizeOf<storage_space_select_request>()).asObjectPool();
    _spaceUpdateRequests = pools.register<storage_space_update_request>(sizeOf<storage_space_update_request>()).asObjectPool();
    _spaceUpsertRequests = pools.register<storage_space_upsert_request>(sizeOf<storage_space_upsert_request>()).asObjectPool();
    _spaceIteratorRequests = pools.register<storage_space_iterator_request>(sizeOf<storage_space_iterator_request>()).asObjectPool();
    _indexRequests = pools.register<storage_index_request>(sizeOf<storage_index_request>()).asObjectPool();
    _indexCountRequests = pools.register<storage_index_count_request>(sizeOf<storage_index_count_request>()).asObjectPool();
    _indexIdByNameRequests = pools.register<storage_index_id_by_name_request>(sizeOf<storage_index_id_by_name_request>()).asObjectPool();
    _indexUpdateRequests = pools.register<storage_index_update_request>(sizeOf<storage_index_update_request>()).asObjectPool();
    _indexIteratorRequests = pools.register<storage_index_iterator_request>(sizeOf<storage_index_iterator_request>()).asObjectPool();
    _callRequests = pools.register<storage_call_request>(sizeOf<storage_call_request>()).asObjectPool();
    _evaluateRequests = pools.register<storage_evaluate_request>(sizeOf<storage_evaluate_request>()).asObjectPool();
    _indexSelectRequests = pools.register<storage_index_select_request>(sizeOf<storage_index_select_request>()).asObjectPool();
    _indexIdRequests = pools.register<storage_index_id_request>(sizeOf<storage_index_id_request>()).asObjectPool();
  }

  @inline
  Pointer<executor_task> createMessage() => _messages.allocate();

  @inline
  void releaseMessage(Pointer<executor_task> message) => _messages.release(message);

  @inline
  Pointer<executor_task> createSpace(int spaceId, Pointer<Uint8> tuple, int tupleSize) {
    final request = _spaceRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceMessageOffset);
  }

  @inline
  void releaseSpace(Pointer<storage_space_request> request) => _spaceRequests.release(request);

  @inline
  Pointer<executor_task> createSpaceCount(int spaceId, int iteratorType, Pointer<Uint8> key, int keySize) {
    final request = _spaceCountRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceCountMessageOffset);
  }

  @inline
  void releaseSpaceCount(Pointer<storage_space_count_request> request) => _spaceCountRequests.release(request);

  @inline
  Pointer<executor_task> createSpaceSelect(int spaceId, Pointer<Uint8> key, int keySize, int offset, int limit, int iteratorType) {
    final request = _spaceSelectRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.offset = offset;
    request.ref.limit = limit;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceSelectMessageOffset);
  }

  @inline
  void releaseSpaceSelect(Pointer<storage_space_select_request> request) => _spaceSelectRequests.release(request);

  @inline
  Pointer<executor_task> createSpaceUpdate(int spaceId, Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = _spaceUpdateRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.operations = operations;
    request.ref.operations_size = operationsSize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceUpdateMessageOffset);
  }

  @inline
  void releaseSpaceUpdate(Pointer<storage_space_update_request> request) => _spaceUpdateRequests.release(request);

  @inline
  Pointer<executor_task> createSpaceUpsert(int spaceId, Pointer<Uint8> tuple, int tupleSize, Pointer<Uint8> operations, int operationsSize) {
    final request = _spaceUpsertRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.operations = operations;
    request.ref.operations_size = operationsSize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceUpsertMessageOffset);
  }

  @inline
  void releaseSpaceUpsert(Pointer<storage_space_upsert_request> request) => _spaceUpsertRequests.release(request);

  @inline
  Pointer<executor_task> createSpaceIterator(int spaceId, int type, Pointer<Uint8> key, int keySize) {
    final request = _spaceIteratorRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.type = type;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceIteratorMessageOffset);
  }

  @inline
  void releaseSpaceIterator(Pointer<storage_space_iterator_request> request) => _spaceIteratorRequests.release(request);

  @inline
  Pointer<executor_task> createIndex(int spaceId, int indexId, Pointer<Uint8> tuple, int tupleSize) {
    final request = _indexRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _indexMessageOffset);
  }

  @inline
  void releaseIndex(Pointer<storage_index_request> request) => _indexRequests.release(request);

  @inline
  Pointer<executor_task> createIndexCount(int spaceId, int indexId, Pointer<Uint8> key, int keySize, int iteratorType) {
    final request = _indexCountRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _indexCountMessageOffset);
  }

  @inline
  void releaseIndexCount(Pointer<storage_index_count_request> request) => _indexCountRequests.release(request);

  @inline
  Pointer<executor_task> createIndexIdByName(int spaceId, String name) {
    final (nameString, nameLength) = _strings.allocate(name);
    final request = _indexIdByNameRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.name = nameString;
    request.ref.name_length = nameLength;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _indexIdByNameMessageOffset);
  }

  @inline
  void releaseIndexIdByName(Pointer<storage_index_id_by_name_request> request) {
    _strings.free(request.ref.name, request.ref.name_length);
    _indexIdByNameRequests.release(request);
  }

  @inline
  Pointer<executor_task> createIndexId(int spaceId, int indexId) {
    final request = _indexIdRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    return Pointer.fromAddress(request.address + _indexIdMessageOffset);
  }

  @inline
  void releaseIndexId(Pointer<storage_index_id_request> request) => _indexIdRequests.release(request);

  @inline
  Pointer<executor_task> createIndexUpdate(int spaceId, int indexId, Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = _indexUpdateRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _indexUpdateMessageOffset);
  }

  @inline
  void releaseIndexUpdate(Pointer<storage_index_update_request> request) => _indexUpdateRequests.release(request);

  @inline
  Pointer<executor_task> createCall(String function, Pointer<Uint8> input, int inputSize) {
    final (functionString, functionLength) = _strings.allocate(function);
    final request = _callRequests.allocate();
    request.ref.function = functionString;
    request.ref.function_length = functionLength;
    request.ref.input = input;
    request.ref.input_size = inputSize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _callMessageOffset);
  }

  @inline
  void releaseCall(Pointer<storage_call_request> request) {
    _strings.free(request.ref.function, request.ref.function_length);
    _callRequests.release(request);
  }

  @inline
  Pointer<executor_task> createEvaluate(String expression, Pointer<Uint8> input, int inputSize) {
    final (expressionString, expressionLength) = _strings.allocate(expression);
    final request = _evaluateRequests.allocate();
    request.ref.expression = expressionString;
    request.ref.expression_length = expressionLength;
    request.ref.input = input;
    request.ref.input_size = inputSize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _evaluateMessageOffset);
  }

  @inline
  void releaseEvaluate(Pointer<storage_evaluate_request> request) {
    _strings.free(request.ref.expression, request.ref.expression_length);
    _evaluateRequests.release(request);
  }

  @inline
  Pointer<executor_task> createIndexIterator(int spaceId, int indexId, int type, Pointer<Uint8> key, int keySize) {
    final request = _indexIteratorRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.type = type;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _indexIteratorMessageOffset);
  }

  @inline
  void releaseIndexIterator(Pointer<storage_index_iterator_request> request) => _indexIteratorRequests.release(request);

  @inline
  Pointer<executor_task> createIndexSelect(int spaceId, int indexId, Pointer<Uint8> key, int keySize, int offset, int limit, int type) {
    final request = _indexSelectRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.iterator_type = type;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.offset = offset;
    request.ref.limit = limit;
    request.ref.task.input = request.cast();
    return Pointer.fromAddress(request.address + _indexSelectMessageOffset);
  }

  @inline
  void releaseIndexSelect(Pointer<storage_index_select_request> request) => _indexSelectRequests.release(request);

  Pointer<executor_task> createString(String string) {
    final (nativeString, nativeStringLength) = _strings.allocate(string);
    final message = _messages.allocate();
    message.ref.input = nativeString.cast();
    message.ref.input_size = nativeStringLength;
    return message;
  }

  @inline
  void releaseString(Pointer<executor_task> message) {
    _strings.free(message.getInputObject(), message.inputSize);
    _messages.release(message);
  }
}
