import 'dart:ffi';

import 'package:core/core.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'strings.dart';

class StorageFactory {
  final StorageStrings _strings;

  late final MemoryObjects<Pointer<interactor_message>> _messages;

  final _spaceMessageOffset = sizeOf<tarantool_space_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_space_request>> _spaceRequests;

  final _spaceCountMessageOffset = sizeOf<tarantool_space_count_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_space_count_request>> _spaceCountRequests;

  final _spaceSelectMessageOffset = sizeOf<tarantool_space_select_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_space_select_request>> _spaceSelectRequests;

  final _spaceUpdateMessageOffset = sizeOf<tarantool_space_update_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_space_update_request>> _spaceUpdateRequests;

  final _spaceUpsertMessageOffset = sizeOf<tarantool_space_upsert_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_space_upsert_request>> _spaceUpsertRequests;

  final _spaceIteratorMessageOffset = sizeOf<tarantool_space_iterator_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_space_iterator_request>> _spaceIteratorRequests;

  final _indexMessageOffset = sizeOf<tarantool_index_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_request>> _indexRequests;

  final _indexCountMessageOffset = sizeOf<tarantool_index_count_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_count_request>> _indexCountRequests;

  final _indexIdByNameMessageOffset = sizeOf<tarantool_index_id_by_name_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_id_by_name_request>> _indexIdByNameRequests;

  final _indexUpdateMessageOffset = sizeOf<tarantool_index_update_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_update_request>> _indexUpdateRequests;

  final _indexIteratorMessageOffset = sizeOf<tarantool_index_iterator_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_iterator_request>> _indexIteratorRequests;

  final _callMessageOffset = sizeOf<tarantool_call_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_call_request>> _callRequests;

  final _evaluateMessageOffset = sizeOf<tarantool_evaluate_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_evaluate_request>> _evaluateRequests;

  final _indexSelectMessageOffset = sizeOf<tarantool_index_select_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_select_request>> _indexSelectRequests;

  final _indexIdMessageOffset = sizeOf<tarantool_index_id_request>() - interactorMessageSize;
  late final MemoryObjects<Pointer<tarantool_index_id_request>> _indexIdRequests;

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
    _indexIdByNameRequests = memory.structures.register<tarantool_index_id_by_name_request>(sizeOf<tarantool_index_id_by_name_request>()).asObjectPool();
    _indexUpdateRequests = memory.structures.register<tarantool_index_update_request>(sizeOf<tarantool_index_update_request>()).asObjectPool();
    _indexIteratorRequests = memory.structures.register<tarantool_index_iterator_request>(sizeOf<tarantool_index_iterator_request>()).asObjectPool();
    _callRequests = memory.structures.register<tarantool_call_request>(sizeOf<tarantool_call_request>()).asObjectPool();
    _evaluateRequests = memory.structures.register<tarantool_evaluate_request>(sizeOf<tarantool_evaluate_request>()).asObjectPool();
    _indexSelectRequests = memory.structures.register<tarantool_index_select_request>(sizeOf<tarantool_index_select_request>()).asObjectPool();
    _indexIdRequests = memory.structures.register<tarantool_index_id_request>(sizeOf<tarantool_index_id_request>()).asObjectPool();
  }

  @inline
  Pointer<interactor_message> createMessage() => _messages.allocate();

  @inline
  void releaseMessage(Pointer<interactor_message> message) => _messages.release(message);

  @inline
  Pointer<interactor_message> createSpace(int spaceId, Pointer<Uint8> tuple, int tupleSize) {
    final request = _spaceRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.tuple = tuple;
    request.ref.tuple_size = tupleSize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceMessageOffset);
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
    return Pointer.fromAddress(request.address + _spaceCountMessageOffset);
  }

  @inline
  void releaseSpaceCount(Pointer<tarantool_space_count_request> request) => _spaceCountRequests.release(request);

  @inline
  Pointer<interactor_message> createSpaceSelect(int spaceId, Pointer<Uint8> key, int keySize, int offset, int limit, int iteratorType) {
    final request = _spaceSelectRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.offset = offset;
    request.ref.limit = limit;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _spaceSelectMessageOffset);
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
    return Pointer.fromAddress(request.address + _spaceUpdateMessageOffset);
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
    return Pointer.fromAddress(request.address + _spaceUpsertMessageOffset);
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
    return Pointer.fromAddress(request.address + _spaceIteratorMessageOffset);
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
    return Pointer.fromAddress(request.address + _indexMessageOffset);
  }

  @inline
  void releaseIndex(Pointer<tarantool_index_request> request) => _indexRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexCount(int spaceId, int indexId, Pointer<Uint8> key, int keySize, int iteratorType) {
    final request = _indexCountRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.iterator_type = iteratorType;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexCountMessageOffset);
  }

  @inline
  void releaseIndexCount(Pointer<tarantool_index_count_request> request) => _indexCountRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexIdByName(int spaceId, String name) {
    final (nameString, nameLength) = _strings.allocate(name);
    final request = _indexIdByNameRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.name = nameString;
    request.ref.name_length = nameLength;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexIdByNameMessageOffset);
  }

  @inline
  void releaseIndexIdByName(Pointer<tarantool_index_id_by_name_request> request) {
    _strings.free(request.ref.name, request.ref.name_length);
    _indexIdByNameRequests.release(request);
  }

  @inline
  Pointer<interactor_message> createIndexId(int spaceId, int indexId) {
    final request = _indexIdRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    return Pointer.fromAddress(request.address + _indexIdMessageOffset);
  }

  @inline
  void releaseIndexId(Pointer<tarantool_index_id_request> request) => _indexIdRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexUpdate(int spaceId, int indexId, Pointer<Uint8> key, int keySize, Pointer<Uint8> operations, int operationsSize) {
    final request = _indexUpdateRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexUpdateMessageOffset);
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
    return Pointer.fromAddress(request.address + _callMessageOffset);
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
    return Pointer.fromAddress(request.address + _evaluateMessageOffset);
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
    return Pointer.fromAddress(request.address + _indexIteratorMessageOffset);
  }

  @inline
  void releaseIndexIterator(Pointer<tarantool_index_iterator_request> request) => _indexIteratorRequests.release(request);

  @inline
  Pointer<interactor_message> createIndexSelect(int spaceId, int indexId, Pointer<Uint8> key, int keySize, int offset, int limit, int type) {
    final request = _indexSelectRequests.allocate();
    request.ref.space_id = spaceId;
    request.ref.index_id = indexId;
    request.ref.iterator_type = type;
    request.ref.key = key;
    request.ref.key_size = keySize;
    request.ref.offset = offset;
    request.ref.limit = limit;
    request.ref.message.input = request.cast();
    return Pointer.fromAddress(request.address + _indexSelectMessageOffset);
  }

  @inline
  void releaseIndexSelect(Pointer<tarantool_index_select_request> request) => _indexSelectRequests.release(request);

  Pointer<interactor_message> createString(String string) {
    final (nativeString, nativeStringLength) = _strings.allocate(string);
    final message = _messages.allocate();
    message.ref.input = nativeString.cast();
    message.ref.input_size = nativeStringLength;
    return message;
  }

  @inline
  void releaseString(Pointer<interactor_message> message) {
    _strings.free(message.getInputObject(), message.inputSize);
    _messages.release(message);
  }
}
