import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart';

class ExecutorModuleConfiguration implements ModuleConfiguration {
  final ExecutorSchedulerConfiguration schedulerConfiguration;

  const ExecutorModuleConfiguration(this.schedulerConfiguration);

  Pointer<executor_module_configuration> toNative(Arena allocator) {
    Pointer<executor_module_configuration> native = allocator();
    native.ref.scheduler_configuration = schedulerConfiguration.toNative(allocator);
    return native;
  }

  factory ExecutorModuleConfiguration.fromNative(Pointer<executor_module_configuration> native) => ExecutorModuleConfiguration(
        ExecutorSchedulerConfiguration.fromNative(native.ref.scheduler_configuration),
      );
}

class ExecutorConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int ringSize;
  final int ringFlags;
  final int memorySlabSize;
  final int memoryPreallocationSize;
  final int memoryQuotaSize;

  Pointer<executor_configuration> toNative(Pointer<executor_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.slab_size = memorySlabSize;
    native.ref.preallocation_size = memoryPreallocationSize;
    native.ref.quota_size = memoryQuotaSize;
    return native;
  }

  factory ExecutorConfiguration.fromNative(Pointer<executor_configuration> native) => ExecutorConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        staticBufferSize: native.ref.static_buffer_size,
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        memorySlabSize: native.ref.slab_size,
        memoryPreallocationSize: native.ref.preallocation_size,
        memoryQuotaSize: native.ref.quota_size,
      );

  const ExecutorConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.ringSize,
    required this.ringFlags,
    required this.memorySlabSize,
    required this.memoryPreallocationSize,
    required this.memoryQuotaSize,
  });

  ExecutorConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? ringSize,
    int? ringFlags,
    Duration? timeoutCheckerPeriod,
    int? memorySlabSize,
    int? memoryPreallocationSize,
    int? memoryQuotaSize,
  }) =>
      ExecutorConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        memorySlabSize: memorySlabSize ?? this.memorySlabSize,
        memoryPreallocationSize: memoryPreallocationSize ?? this.memoryPreallocationSize,
        memoryQuotaSize: memoryQuotaSize ?? this.memoryQuotaSize,
      );
}

class ExecutorSchedulerConfiguration {
  final int ringSize;
  final int ringFlags;
  final Duration initializationTimeout;
  final Duration shutdownTimeout;

  Pointer<executor_scheduler_configuration> toNative(Arena allocator) {
    Pointer<executor_scheduler_configuration> native = allocator();
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.initialization_timeout_seconds = initializationTimeout.inSeconds;
    native.ref.shutdown_timeout_seconds = shutdownTimeout.inSeconds;
    return native;
  }

  factory ExecutorSchedulerConfiguration.fromNative(Pointer<executor_scheduler_configuration> native) => ExecutorSchedulerConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        initializationTimeout: Duration(seconds: native.ref.initialization_timeout_seconds),
        shutdownTimeout: Duration(seconds: native.ref.shutdown_timeout_seconds),
      );

  const ExecutorSchedulerConfiguration({
    required this.ringSize,
    required this.ringFlags,
    required this.initializationTimeout,
    required this.shutdownTimeout,
  });

  ExecutorSchedulerConfiguration copyWith({
    int? ringSize,
    int? ringFlags,
    Duration? initializationTimeout,
    Duration? shutdownTimeout,
    int? completionPeekCount,
  }) =>
      ExecutorSchedulerConfiguration(
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        initializationTimeout: initializationTimeout ?? this.initializationTimeout,
        shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
      );
}
