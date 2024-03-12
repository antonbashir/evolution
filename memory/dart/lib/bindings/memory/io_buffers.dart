// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import '../../memory/bindings.dart';

final class memory_io_buffers extends Struct {
  external Pointer<memory> memory_instance;
}

@Native<Pointer<memory_io_buffers> Function(Pointer<memory> memory)>(isLeaf: true)
external Pointer<memory_io_buffers> memory_io_buffers_create(Pointer<memory> memory);

@Native<Void Function(Pointer<memory_io_buffers> pool)>(isLeaf: true)
external void memory_io_buffers_destroy(Pointer<memory_io_buffers> pool);

@Native<Pointer<memory_input_buffer> Function(Pointer<memory_io_buffers> buffers, Size initial_capacity)>(isLeaf: true)
external Pointer<memory_input_buffer> memory_io_buffers_allocate_input(Pointer<memory_io_buffers> buffers, int initial_capacity);

@Native<Void Function(Pointer<memory_io_buffers> buffers, Pointer<memory_input_buffer> buffer)>(isLeaf: true)
external void memory_io_buffers_free_input(Pointer<memory_io_buffers> buffers, Pointer<memory_input_buffer> buffer);

@Native<Pointer<memory_output_buffer> Function(Pointer<memory_io_buffers> buffers, Size initial_capacity)>(isLeaf: true)
external Pointer<memory_output_buffer> memory_io_buffers_allocate_output(Pointer<memory_io_buffers> buffers, int initial_capacity);

@Native<Void Function(Pointer<memory_io_buffers> buffers, Pointer<memory_output_buffer> buffer)>(isLeaf: true)
external void memory_io_buffers_free_output(Pointer<memory_io_buffers> buffers, Pointer<memory_output_buffer> buffer);

@Native<Pointer<Uint8> Function(Pointer<memory_input_buffer> buffer, Size size)>(isLeaf: true)
external Pointer<Uint8> memory_input_buffer_reserve(Pointer<memory_input_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_input_buffer> buffer, Size size)>(isLeaf: true)
external Pointer<Uint8> memory_input_buffer_finalize(Pointer<memory_input_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_input_buffer> buffer, Size delta, Size size)>(isLeaf: true)
external Pointer<Uint8> memory_input_buffer_finalize_reserve(Pointer<memory_input_buffer> buffer, int delta, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_output_buffer> buffer, Size size)>(isLeaf: true)
external Pointer<Uint8> memory_output_buffer_reserve(Pointer<memory_output_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_output_buffer> buffer, Size size)>(isLeaf: true)
external Pointer<Uint8> memory_output_buffer_finalize(Pointer<memory_output_buffer> buffer, int size);

@Native<Pointer<Uint8> Function(Pointer<memory_output_buffer> buffer, Size delta, Size size)>(isLeaf: true)
external Pointer<Uint8> memory_output_buffer_finalize_reserve(Pointer<memory_output_buffer> buffer, int delta, int size);
