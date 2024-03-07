import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:executor/executor.dart';
import 'package:memory/memory.dart';
import 'package:memory/memory/defaults.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'factory.dart';
import 'schema.dart';
import 'strings.dart';

class StorageProducer implements ExecutorProducer {
  final Pointer<tarantool_box> _box;

  StorageProducer(this._box);

  late final ExecutorMethod evaluate;
  late final ExecutorMethod call;
  late final ExecutorMethod freeOutputBuffer;
  late final ExecutorMethod iteratorNextSingle;
  late final ExecutorMethod iteratorNextMany;
  late final ExecutorMethod iteratorDestroy;
  late final ExecutorMethod spaceIdByName;
  late final ExecutorMethod spaceCount;
  late final ExecutorMethod spaceLength;
  late final ExecutorMethod spaceIterator;
  late final ExecutorMethod spaceInsertSingle;
  late final ExecutorMethod spaceInsertMany;
  late final ExecutorMethod spacePutSingle;
  late final ExecutorMethod spacePutMany;
  late final ExecutorMethod spaceDeleteSingle;
  late final ExecutorMethod spaceDeleteMany;
  late final ExecutorMethod spaceUpdateSingle;
  late final ExecutorMethod spaceUpdateMany;
  late final ExecutorMethod spaceGet;
  late final ExecutorMethod spaceMin;
  late final ExecutorMethod spaceMax;
  late final ExecutorMethod spaceTruncate;
  late final ExecutorMethod spaceUpsert;
  late final ExecutorMethod indexCount;
  late final ExecutorMethod indexLength;
  late final ExecutorMethod indexIterator;
  late final ExecutorMethod indexGet;
  late final ExecutorMethod indexMax;
  late final ExecutorMethod indexMin;
  late final ExecutorMethod indexUpdateSingle;
  late final ExecutorMethod indexUpdateMany;
  late final ExecutorMethod indexSelect;
  late final ExecutorMethod indexIdByName;

  @override
  void initialize(ExecutorProducerRegistrat registrat) {
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

class StorageConsumer implements ExecutorConsumer {
  StorageConsumer();

  @override
  List<ExecutorCallback> callbacks() => [];
}

class StorageExecutor {
  final Pointer<tarantool_box> _box;

  late final StorageSchema _schema;
  late final Executor _executor;
  late final int _descriptor;
  late final MemoryTuples _tuples;
  late final StorageProducer _producer;
  late final Pointer<tarantool_factory> _nativeFactory;
  late final StorageStrings _strings;
  late final StorageFactory _factory;

  StorageExecutor(this._box);

  StorageSchema get schema => _schema;
  MemoryTuples get tuples => _tuples;
  MemoryModule get memory => _executor.memory;

  Future<void> initialize(ExecutorModule executorModule) async {
    _executor = Executor(executorModule.executor());
    await _executor.initialize();
    _descriptor = tarantool_executor_descriptor();
    _nativeFactory = calloc<tarantool_factory>(sizeOf<tarantool_factory>());
    using((Arena arena) {
      final configuration = arena<tarantool_factory_configuration>();
      configuration.ref.quota_size = MemoryDefaults.module.quotaSize;
      configuration.ref.preallocation_size = MemoryDefaults.module.preallocationSize;
      configuration.ref.slab_size = MemoryDefaults.module.slabSize;
      tarantool_factory_initialize(_nativeFactory, configuration);
    });
    _executor.consumer(StorageConsumer());
    _producer = _executor.producer(StorageProducer(_box));
    _tuples = MemoryTuples(_executor.memory.pointer);
    _strings = StorageStrings(_nativeFactory);
    _factory = StorageFactory(memory, _strings);
    _schema = StorageSchema(_descriptor, this, _tuples, _producer, _factory);
    _executor.activate();
  }

  void stop() => _executor.deactivate();

  Future<void> destroy() async {
    tarantool_factory_destroy(_nativeFactory);
    calloc.free(_nativeFactory.cast());
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
    final (pointer, buffer, data) = _tuples.prepareSmall(size);
    configuration.serialize(buffer, data, 0);
    return call(LuaExpressions.boot, input: pointer, inputSize: size);
  }

  @inline
  Future<(Uint8List, void Function())> evaluate(String expression, {Pointer<Uint8>? input, int inputSize = 0}) {
    if (input != null) {
      return _producer.evaluate(_descriptor, _factory.createEvaluate(expression, input, inputSize)).then(_parseLuaEvaluate);
    }
    (input, inputSize) = _tuples.emptyList;
    return _producer.evaluate(_descriptor, _factory.createEvaluate(expression, input, inputSize)).then(_parseLuaEvaluate);
  }

  @inline
  Future<(Uint8List, void Function())> call(String function, {Pointer<Uint8>? input, int inputSize = 0}) {
    if (input != null) {
      return _producer.call(_descriptor, _factory.createCall(function, input, inputSize)).then(_parseLuaCall);
    }
    (input, inputSize) = _tuples.emptyList;
    return _producer.call(_descriptor, _factory.createCall(function, input, inputSize)).then(_parseLuaCall);
  }

  @inline
  Future<void> file(File file) => file.readAsString().then(evaluate);

  @inline
  Future<void> require(String module) => evaluate(LuaExpressions.require(module));

  @inline
  (Uint8List, void Function()) _parseLuaEvaluate(Pointer<executor_task> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = buffer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseEvaluate(message.getInputObject());
    return (result, () {});
  }

  @inline
  (Uint8List, void Function()) _parseLuaCall(Pointer<executor_task> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = message.outputPointer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseCall(message.getInputObject());
    return (result, () {});
  }
}
