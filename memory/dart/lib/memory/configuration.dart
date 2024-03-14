import 'dart:ffi';

import 'bindings.dart';

class MemoryModuleConfiguration implements ModuleConfiguration {
  final LibraryPackageMode libraryPackageMode;

  const MemoryModuleConfiguration({required this.libraryPackageMode});

  factory MemoryModuleConfiguration.fromNative(Pointer<memory_module_configuration> native) => MemoryModuleConfiguration(
        libraryPackageMode: LibraryPackageMode.values[native.ref.library_package_mode],
      );

  Pointer<memory_module_configuration> toNative(Pointer<memory_module_configuration> native) {
    native.ref.library_package_mode = libraryPackageMode.index;
    return native;
  }
}

class MemoryConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int slabSize;
  final int preallocationSize;
  final int quotaSize;
  final double smallAllocationFactor;

  factory MemoryConfiguration.fromNative(Pointer<memory_configuration> native) => MemoryConfiguration(
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        staticBufferSize: native.ref.static_buffer_size,
        slabSize: native.ref.slab_size,
        preallocationSize: native.ref.preallocation_size,
        quotaSize: native.ref.quota_size,
        smallAllocationFactor: native.ref.small_allocation_factor,
      );

  Pointer<memory_configuration> toNative(Pointer<memory_configuration> native) {
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.slab_size = slabSize;
    native.ref.preallocation_size = preallocationSize;
    native.ref.quota_size = quotaSize;
    native.ref.small_allocation_factor = smallAllocationFactor;
    return native;
  }

  const MemoryConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.slabSize,
    required this.preallocationSize,
    required this.quotaSize,
    required this.smallAllocationFactor,
  });

  MemoryConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? slabSize,
    int? preallocationSize,
    int? quotaSize,
    double? smallAllocationFactor,
  }) =>
      MemoryConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        slabSize: slabSize ?? this.slabSize,
        preallocationSize: preallocationSize ?? this.preallocationSize,
        quotaSize: quotaSize ?? this.quotaSize,
        smallAllocationFactor: smallAllocationFactor ?? this.smallAllocationFactor,
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
