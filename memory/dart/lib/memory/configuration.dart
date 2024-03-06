import 'dart:ffi';

import '../bindings/include/memory_configuration.dart';

class MemoryModuleConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int slabSize;
  final int preallocationSize;
  final int quotaSize;

  factory MemoryModuleConfiguration.fromNativePointer(Pointer<memory_configuration> native) => MemoryModuleConfiguration(
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        staticBufferSize: native.ref.static_buffer_size,
        slabSize: native.ref.slab_size,
        preallocationSize: native.ref.preallocation_size,
        quotaSize: native.ref.quota_size,
      );

  factory MemoryModuleConfiguration.fromNativeValue(memory_configuration native) => MemoryModuleConfiguration(
        staticBuffersCapacity: native.static_buffers_capacity,
        staticBufferSize: native.static_buffer_size,
        slabSize: native.slab_size,
        preallocationSize: native.preallocation_size,
        quotaSize: native.quota_size,
      );

  Pointer<memory_configuration> toNativePointer(Pointer<memory_configuration> native) {
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.slab_size = slabSize;
    native.ref.preallocation_size = preallocationSize;
    native.ref.quota_size = quotaSize;
    return native;
  }

  memory_configuration toNativeValue(memory_configuration native) {
    native.static_buffer_size = staticBufferSize;
    native.static_buffers_capacity = staticBuffersCapacity;
    native.slab_size = slabSize;
    native.preallocation_size = preallocationSize;
    native.quota_size = quotaSize;
    return native;
  }

  const MemoryModuleConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.slabSize,
    required this.preallocationSize,
    required this.quotaSize,
  });

  MemoryModuleConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? slabSize,
    int? preallocationSize,
    int? quotaSize,
  }) =>
      MemoryModuleConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        slabSize: slabSize ?? this.slabSize,
        preallocationSize: preallocationSize ?? this.preallocationSize,
        quotaSize: quotaSize ?? this.quotaSize,
      );
}

class MemoryObjectsConfiguration {
  final int initialCapacity;
  final int minimumAvailableCapacity;
  final int maximumAvailableCapacity;
  final int preallocation;
  final double extensionFactor;
  final double shrinkFactor;

  const MemoryObjectsConfiguration({
    required this.initialCapacity,
    required this.minimumAvailableCapacity,
    required this.maximumAvailableCapacity,
    required this.preallocation,
    required this.extensionFactor,
    required this.shrinkFactor,
  });
}
