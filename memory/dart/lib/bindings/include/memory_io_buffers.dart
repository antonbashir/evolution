import 'dart:ffi';

import 'package:core/core.dart';

import 'memory.dart';

final class memory_io_buffers extends Opaque {}

final class memory_input_buffer extends Struct {
  external Pointer<Uint8> read_position;
  external Pointer<Uint8> write_position;
}

final class memory_output_buffer extends Struct {
  external Pointer<iovec> content;
}

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
