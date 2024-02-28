import 'dart:ffi';

import 'bindings.dart';

class MemoryModuleConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int slabSize;
  final int preallocationSize;
  final int quotaSize;

  factory MemoryModuleConfiguration.fromNative(Pointer<memory_module_configuration> native) => MemoryModuleConfiguration(
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        staticBufferSize: native.ref.static_buffer_size,
        slabSize: native.ref.slab_size,
        preallocationSize: native.ref.preallocation_size,
        quotaSize: native.ref.quota_size,
      );

  Pointer<memory_module_configuration> toNative(Pointer<memory_module_configuration> native) {
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.slab_size = slabSize;
    native.ref.preallocation_size = preallocationSize;
    native.ref.quota_size = quotaSize;
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
  final int minimalAvailableCapacity;
  final int preallocation;
  final double extensionFactor;
  final double shrinkFactor;

  const MemoryObjectsConfiguration({
    required this.initialCapacity,
    required this.minimalAvailableCapacity,
    required this.preallocation,
    required this.extensionFactor,
    required this.shrinkFactor,
  });
}
