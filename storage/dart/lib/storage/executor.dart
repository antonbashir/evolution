import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:interactor/interactor.dart';
import 'package:memory/memory.dart';
import 'package:memory/memory/defaults.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'factory.dart';
import 'schema.dart';
import 'strings.dart';

class StorageProducer implements InteractorProducer {
  final Pointer<tarantool_box> _box;

  StorageProducer(this._box);

  late final InteractorMethod evaluate;
  late final InteractorMethod call;
  late final InteractorMethod freeOutputBuffer;
  late final InteractorMethod iteratorNextSingle;
  late final InteractorMethod iteratorNextMany;
  late final InteractorMethod iteratorDestroy;
  late final InteractorMethod spaceIdByName;
  late final InteractorMethod spaceCount;
  late final InteractorMethod spaceLength;
  late final InteractorMethod spaceIterator;
  late final InteractorMethod spaceInsertSingle;
  late final InteractorMethod spaceInsertMany;
  late final InteractorMethod spacePutSingle;
  late final InteractorMethod spacePutMany;
  late final InteractorMethod spaceDeleteSingle;
  late final InteractorMethod spaceDeleteMany;
  late final InteractorMethod spaceUpdateSingle;
  late final InteractorMethod spaceUpdateMany;
  late final InteractorMethod spaceGet;
  late final InteractorMethod spaceMin;
  late final InteractorMethod spaceMax;
  late final InteractorMethod spaceTruncate;
  late final InteractorMethod spaceUpsert;
  late final InteractorMethod indexCount;
  late final InteractorMethod indexLength;
  late final InteractorMethod indexIterator;
  late final InteractorMethod indexGet;
  late final InteractorMethod indexMax;
  late final InteractorMethod indexMin;
  late final InteractorMethod indexUpdateSingle;
  late final InteractorMethod indexUpdateMany;
  late final InteractorMethod indexSelect;
  late final InteractorMethod indexIdByName;

  @override
  void initialize(InteractorProducerRegistrat registrat) {
    evaluate = registrat.register(_box.ref.tarantool_evaluate_address);
    call = registrat.register(_box.ref.tarantool_call_address);
    iteratorNextSingle = registrat.register(_box.ref.tarantool_iterator_next_single_address);
    iteratorNextMany = registrat.register(_box.ref.tarantool_iterator_next_many_address);
    iteratorDestroy = registrat.register(_box.ref.tarantool_iterator_destroy_address);
    freeOutputBuffer = registrat.register(_box.ref.tarantool_free_output_buffer_address);
    spaceIdByName = registrat.register(_box.ref.tarantool_space_id_by_name_address);
    spaceCount = registrat.register(_box.ref.tarantool_space_count_address);
    spaceLength = registrat.register(_box.ref.tarantool_space_length_address);
    spaceIterator = registrat.register(_box.ref.tarantool_space_iterator_address);
    spaceInsertSingle = registrat.register(_box.ref.tarantool_space_insert_single_address);
    spaceInsertMany = registrat.register(_box.ref.tarantool_space_insert_many_address);
    spacePutSingle = registrat.register(_box.ref.tarantool_space_put_single_address);
    spacePutMany = registrat.register(_box.ref.tarantool_space_put_many_address);
    spaceDeleteSingle = registrat.register(_box.ref.tarantool_space_delete_single_address);
    spaceDeleteMany = registrat.register(_box.ref.tarantool_space_delete_many_address);
    spaceUpdateSingle = registrat.register(_box.ref.tarantool_space_update_single_address);
    spaceUpdateMany = registrat.register(_box.ref.tarantool_space_update_many_address);
    spaceGet = registrat.register(_box.ref.tarantool_space_get_address);
    spaceMin = registrat.register(_box.ref.tarantool_space_min_address);
    spaceMax = registrat.register(_box.ref.tarantool_space_max_address);
    spaceTruncate = registrat.register(_box.ref.tarantool_space_truncate_address);
    spaceUpsert = registrat.register(_box.ref.tarantool_space_upsert_address);
    indexCount = registrat.register(_box.ref.tarantool_index_count_address);
    indexLength = registrat.register(_box.ref.tarantool_index_length_address);
    indexIterator = registrat.register(_box.ref.tarantool_index_iterator_address);
    indexGet = registrat.register(_box.ref.tarantool_index_get_address);
    indexMax = registrat.register(_box.ref.tarantool_index_max_address);
    indexMin = registrat.register(_box.ref.tarantool_index_min_address);
    indexUpdateSingle = registrat.register(_box.ref.tarantool_index_update_single_address);
    indexUpdateMany = registrat.register(_box.ref.tarantool_index_update_many_address);
    indexSelect = registrat.register(_box.ref.tarantool_index_select_address);
    indexIdByName = registrat.register(_box.ref.tarantool_index_id_by_name_address);
  }
}

class StorageConsumer implements InteractorConsumer {
  StorageConsumer();

  @override
  List<InteractorCallback> callbacks() => [];
}

class StorageExecutor {
  final interactors = InteractorModule();

  final Pointer<tarantool_box> _box;

  late final StorageSchema _schema;
  late final Interactor _interactor;
  late final int _descriptor;
  late final MemoryTuples _tuples;
  late final StorageProducer _producer;
  late final Pointer<tarantool_factory> _nativeFactory;
  late final StorageStrings _strings;
  late final StorageFactory _factory;

  StorageExecutor(this._box);

  StorageSchema get schema => _schema;
  MemoryTuples get tuples => _tuples;
  MemoryModule get memory => _interactor.memory;

  Future<void> initialize() async {
    _interactor = Interactor(interactors.interactor());
    await _interactor.initialize(sharedMemoryLibrary: true);
    _descriptor = tarantool_executor_descriptor();
    _nativeFactory = calloc<tarantool_factory>(sizeOf<tarantool_factory>());
    using((Arena arena) {
      final configuration = arena<tarantool_factory_configuration>();
      configuration.ref.quota_size = MemoryDefaults.memory.quotaSize;
      configuration.ref.preallocation_size = MemoryDefaults.memory.preallocationSize;
      configuration.ref.slab_size = MemoryDefaults.memory.slabSize;
      tarantool_factory_initialize(_nativeFactory, configuration);
    });
    _interactor.consumer(StorageConsumer());
    _producer = _interactor.producer(StorageProducer(_box));
    _tuples = MemoryTuples(_interactor.memory.pointer);
    _strings = StorageStrings(_nativeFactory);
    _schema = StorageSchema(_descriptor, _nativeFactory, this, _tuples, _strings, _producer);
    _factory = StorageFactory(memory, _strings);
    _interactor.activate();
  }

  Future<void> stop() => _interactor.deactivate();

  Future<void> destroy() async {
    tarantool_factory_destroy(_nativeFactory);
    calloc.free(_nativeFactory.cast());
    await interactors.shutdown();
  }

  @inline
  Future<void> startBackup() => evaluate(LuaExpressions.startBackup);

  @inline
  Future<void> stopBackup() => evaluate(LuaExpressions.stopBackup);

  @inline
  Future<void> configure(StorageConfiguration configuration) => evaluate(configuration.format());

  @inline
  Future<void> boot(StorageBootConfiguration configuration) {
    final size = configuration.tupleSize;
    final (pointer, buffer, data) = _tuples.prepare(size);
    configuration.serialize(buffer, data, 0);
    return call(LuaExpressions.boot, input: pointer, inputSize: size);
  }

  @inline
  Future<(Uint8List, void Function())> evaluate(String expression, {Pointer<Uint8>? input, int inputSize = 0}) {
    if (input != null) {
      return _producer.evaluate(_descriptor, _factory.prepareEvaluate(expression, input, inputSize)).then(_parseLuaEvaluate);
    }
    (input, inputSize) = _tuples.emptyList;
    return _producer.evaluate(_descriptor, _factory.prepareEvaluate(expression, input, inputSize)).then(_parseLuaEvaluate);
  }

  @inline
  Future<(Uint8List, void Function())> call(String function, {Pointer<Uint8>? input, int inputSize = 0}) {
    if (input != null) {
      return _producer.call(_descriptor, _factory.prepareCall(function, input, inputSize)).then(_parseLuaCall);
    }
    (input, inputSize) = _tuples.emptyList;
    return _producer.call(_descriptor, _factory.prepareCall(function, input, inputSize)).then(_parseLuaCall);
  }

  @inline
  Future<void> file(File file) => file.readAsString().then(evaluate);

  @inline
  Future<void> require(String module) => evaluate(LuaExpressions.require(module));

  @inline
  (Uint8List, void Function()) _parseLuaEvaluate(Pointer<interactor_message> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = buffer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseEvaluate(message.getInputObject());
    return (result, () {});
  }

  @inline
  (Uint8List, void Function()) _parseLuaCall(Pointer<interactor_message> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = message.outputPointer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseCall(message.getInputObject());
    return (result, () {});
  }
}
