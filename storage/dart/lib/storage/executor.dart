import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';
import 'package:mediator/mediator.dart';
import 'package:memory/memory.dart';
import 'package:memory/memory/defaults.dart';

import 'bindings.dart';
import 'configuration.dart';
import 'constants.dart';
import 'factory.dart';
import 'schema.dart';
import 'strings.dart';

class StorageProducer implements MediatorProducer {
  final Pointer<tarantool_box> _box;

  StorageProducer(this._box);

  late final MediatorMethod evaluate;
  late final MediatorMethod call;
  late final MediatorMethod freeOutputBuffer;
  late final MediatorMethod iteratorNextSingle;
  late final MediatorMethod iteratorNextMany;
  late final MediatorMethod iteratorDestroy;
  late final MediatorMethod spaceIdByName;
  late final MediatorMethod spaceCount;
  late final MediatorMethod spaceLength;
  late final MediatorMethod spaceIterator;
  late final MediatorMethod spaceInsertSingle;
  late final MediatorMethod spaceInsertMany;
  late final MediatorMethod spacePutSingle;
  late final MediatorMethod spacePutMany;
  late final MediatorMethod spaceDeleteSingle;
  late final MediatorMethod spaceDeleteMany;
  late final MediatorMethod spaceUpdateSingle;
  late final MediatorMethod spaceUpdateMany;
  late final MediatorMethod spaceGet;
  late final MediatorMethod spaceMin;
  late final MediatorMethod spaceMax;
  late final MediatorMethod spaceTruncate;
  late final MediatorMethod spaceUpsert;
  late final MediatorMethod indexCount;
  late final MediatorMethod indexLength;
  late final MediatorMethod indexIterator;
  late final MediatorMethod indexGet;
  late final MediatorMethod indexMax;
  late final MediatorMethod indexMin;
  late final MediatorMethod indexUpdateSingle;
  late final MediatorMethod indexUpdateMany;
  late final MediatorMethod indexSelect;
  late final MediatorMethod indexIdByName;

  @override
  void initialize(MediatorProducerRegistrat registrat) {
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

class StorageConsumer implements MediatorConsumer {
  StorageConsumer();

  @override
  List<MediatorCallback> callbacks() => [];
}

class StorageExecutor {
  final Pointer<tarantool_box> _box;

  late final StorageSchema _schema;
  late final Mediator _mediator;
  late final int _descriptor;
  late final MemoryTuples _tuples;
  late final StorageProducer _producer;
  late final Pointer<tarantool_factory> _nativeFactory;
  late final StorageStrings _strings;
  late final StorageFactory _factory;

  StorageExecutor(this._box);

  StorageSchema get schema => _schema;
  MemoryTuples get tuples => _tuples;
  MemoryModule get memory => _mediator.memory;

  Future<void> initialize(MediatorModule mediatorModule) async {
    _mediator = Mediator(mediatorModule.mediator());
    await _mediator.initialize();
    _descriptor = tarantool_executor_descriptor();
    _nativeFactory = calloc<tarantool_factory>(sizeOf<tarantool_factory>());
    using((Arena arena) {
      final configuration = arena<tarantool_factory_configuration>();
      configuration.ref.quota_size = MemoryDefaults.module.quotaSize;
      configuration.ref.preallocation_size = MemoryDefaults.module.preallocationSize;
      configuration.ref.slab_size = MemoryDefaults.module.slabSize;
      tarantool_factory_initialize(_nativeFactory, configuration);
    });
    _mediator.consumer(StorageConsumer());
    _producer = _mediator.producer(StorageProducer(_box));
    _tuples = MemoryTuples(_mediator.memory.pointer);
    _strings = StorageStrings(_nativeFactory);
    _factory = StorageFactory(memory, _strings);
    _schema = StorageSchema(_descriptor, this, _tuples, _producer, _factory);
    _mediator.activate();
  }

  void stop() => _mediator.deactivate();

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
  (Uint8List, void Function()) _parseLuaEvaluate(Pointer<mediator_message> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = buffer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseEvaluate(message.getInputObject());
    return (result, () {});
  }

  @inline
  (Uint8List, void Function()) _parseLuaCall(Pointer<mediator_message> message) {
    final buffer = message.outputPointer;
    final bufferSize = message.outputSize;
    final result = message.outputPointer.cast<Uint8>().asTypedList(message.outputSize);
    _factory.releaseCall(message.getInputObject());
    return (result, () {});
  }
}
