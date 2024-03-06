import 'dart:ffi';

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
