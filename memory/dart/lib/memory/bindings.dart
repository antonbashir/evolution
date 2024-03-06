import 'dart:ffi';

import 'package:core/core.dart';

@Native<Int32 Function(Pointer<memory_state>, Pointer<memory_configuration>)>(symbol: 'memory_state_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_state_create(Pointer<memory_state> memory, Pointer<memory_configuration> configuration);

@Native<Void Function(Pointer<memory_state>)>(symbol: 'memory_state_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_state_destroy(Pointer<memory_state> memory);

@Native<Uint64 Function(Pointer<Char>, Uint64)>(symbol: 'memory_tuple_next', assetId: 'memory-bindings', isLeaf: true)
external int memory_tuple_next(Pointer<Char> buffer, int offset);

@Native<Int32 Function(Pointer<memory_io_buffers>, Pointer<memory>)>(symbol: 'memory_io_buffers_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_io_buffers_create(Pointer<memory_io_buffers> pool, Pointer<memory> memory);

@Native<Void Function(Pointer<memory_io_buffers>)>(symbol: 'memory_io_buffers_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_io_buffers_destroy(Pointer<memory_io_buffers> pool);

@Native<Pointer<memory_input_buffer> Function(Pointer<memory_io_buffers>, Size)>(symbol: 'memory_io_buffers_allocate_input', assetId: 'memory-bindings', isLeaf: true)
external Pointer<memory_input_buffer> memory_io_buffers_allocate_input(Pointer<memory_io_buffers> buffers, int initial_capacity);

@Native<Void Function(Pointer<memory_io_buffers>, Pointer<memory_input_buffer>)>(symbol: 'memory_io_buffers_free_input', assetId: 'memory-bindings', isLeaf: true)
external void memory_io_buffers_free_input(Pointer<memory_io_buffers> buffers, Pointer<memory_input_buffer> buffer);

@Native<Pointer<memory_output_buffer> Function(Pointer<memory_io_buffers>, Size)>(symbol: 'memory_io_buffers_allocate_output', assetId: 'memory-bindings', isLeaf: true)
external Pointer<memory_output_buffer> memory_io_buffers_allocate_output(Pointer<memory_io_buffers> buffers, int initial_capacity);

@Native<Void Function(Pointer<memory_io_buffers>, Pointer<memory_output_buffer>)>(symbol: 'memory_io_buffers_free_output', assetId: 'memory-bindings', isLeaf: true)
external void memory_io_buffers_free_output(Pointer<memory_io_buffers> buffers, Pointer<memory_output_buffer> buffer);

@Native<Pointer<Uint8> Function(Pointer<memory_input_buffer>, Size)>(symbol: 'memory_input_buffer_reserve', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Uint8> memory_input_buffer_reserve(Pointer<memory_input_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_input_buffer>, Size)>(symbol: 'memory_input_buffer_finalize', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Uint8> memory_input_buffer_finalize(Pointer<memory_input_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_input_buffer>, Size, Size)>(symbol: 'memory_input_buffer_finalize', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Uint8> memory_input_buffer_finalize_reserve(Pointer<memory_input_buffer> buffer, int delta, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_output_buffer>, Size)>(symbol: 'memory_output_buffer_reserve', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Uint8> memory_output_buffer_reserve(Pointer<memory_output_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_output_buffer>, Size)>(symbol: 'memory_output_buffer_finalize', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Uint8> memory_output_buffer_finalize(Pointer<memory_output_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_output_buffer>, Size, Size)>(symbol: 'memory_output_buffer_finalize_reserve', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Uint8> memory_output_buffer_finalize_reserve(Pointer<memory_output_buffer> buffer, int delta, int size);

@Native<Int32 Function(Pointer<memory_small_data>, Pointer<memory>)>(symbol: 'memory_small_data_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_small_data_create(Pointer<memory_small_data> pool, Pointer<memory> memory);

@Native<Void Function(Pointer<memory_small_data>)>(symbol: 'memory_small_data_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_small_data_destroy(Pointer<memory_small_data> pool);

@Native<Pointer<Void> Function(Pointer<memory_small_data>, Size)>(symbol: 'memory_small_data_allocate', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Void> memory_small_data_allocate(Pointer<memory_small_data> pool, int data_size);

@Native<Void Function(Pointer<memory_small_data>, Pointer<Void>, Size)>(symbol: 'memory_small_data_free', assetId: 'memory-bindings', isLeaf: true)
external void memory_small_data_free(Pointer<memory_small_data> pool, Pointer<Void> data, int data_size);

@Native<Int32 Function(Pointer<memory_static_buffers>, Size, Size)>(symbol: 'memory_static_buffers_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_create(Pointer<memory_static_buffers> pool, int capacity, int size);

@Native<Void Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_static_buffers_destroy(Pointer<memory_static_buffers> pool);

@Native<Void Function(Pointer<memory_static_buffers>, Int32)>(symbol: 'memory_static_buffers_push', assetId: 'memory-bindings', isLeaf: true)
external void memory_static_buffers_push(Pointer<memory_static_buffers> pool, int id);

@Native<Int32 Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_pop', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_pop(Pointer<memory_static_buffers> pool);

@Native<Int32 Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_available', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_available(Pointer<memory_static_buffers> pool);

@Native<Int32 Function(Pointer<memory_static_buffers>)>(symbol: 'memory_static_buffers_used', assetId: 'memory-bindings', isLeaf: true)
external int memory_static_buffers_used(Pointer<memory_static_buffers> pool);

@Native<Int32 Function(Pointer<memory_structure_pool>, Pointer<memory>, Size)>(symbol: 'memory_structure_pool_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_structure_pool_create(Pointer<memory_structure_pool> pool, Pointer<memory> memory, int structure_size);

@Native<Void Function(Pointer<memory_structure_pool>)>(symbol: 'memory_structure_pool_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_structure_pool_destroy(Pointer<memory_structure_pool> pool);

@Native<Pointer<Void> Function(Pointer<memory_structure_pool>)>(symbol: 'memory_structure_pool_allocate', assetId: 'memory-bindings', isLeaf: true)
external Pointer<Void> memory_structure_pool_allocate(Pointer<memory_structure_pool> pool);

@Native<Void Function(Pointer<memory_structure_pool>, Pointer<Void>)>(symbol: 'memory_structure_pool_free', assetId: 'memory-bindings', isLeaf: true)
external void memory_structure_pool_free(Pointer<memory_structure_pool> pool, Pointer<Void> payload);

@Native<Pointer<memory_structure_pool> Function()>(symbol: 'memory_structure_pool_new', assetId: 'memory-bindings', isLeaf: true)
external Pointer<memory_structure_pool> memory_structure_pool_new();

final class memory_state extends Struct {
  external Pointer<memory_static_buffers> static_buffers;
  external Pointer<memory_io_buffers> io_buffers;
  external Pointer<memory_small_data> small_data;
  external Pointer<memory> memory_instance;
}

final class memory_configuration extends Struct {
  @Size()
  external int quota_size;

  @Size()
  external int preallocation_size;

  @Size()
  external int slab_size;

  @Size()
  external int static_buffers_capacity;

  @Size()
  external int static_buffer_size;
}

final class memory extends Opaque {}

final class memory_io_buffers extends Opaque {}

final class memory_input_buffer extends Struct {
  external Pointer<Uint8> read_position;
  external Pointer<Uint8> write_position;
}

final class memory_output_buffer extends Struct {
  external Pointer<iovec> content;
}

final class memory_small_data extends Opaque {}

final class memory_static_buffers extends Struct {
  @Size()
  external int available;
  @Size()
  external int size;
  @Size()
  external int capacity;
  external Pointer<Int32> ids;
  external Pointer<iovec> buffers;
}

final class memory_structure_pool extends Struct {
  @Size()
  external int size;
}
