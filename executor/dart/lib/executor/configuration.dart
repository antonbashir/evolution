import 'dart:ffi';

import 'bindings.dart';

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

class ExecutorNotifierConfiguration {
  final int ringSize;
  final int ringFlags;
  final Duration initializationTimeout;
  final Duration shutdownTimeout;

  Pointer<executor_scheduler_configuration> toNative(Pointer<executor_scheduler_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.initialization_timeout_seconds = initializationTimeout.inSeconds;
    native.ref.shutdown_timeout_seconds = shutdownTimeout.inSeconds;
    return native;
  }

  factory ExecutorNotifierConfiguration.fromNative(Pointer<executor_scheduler_configuration> native) => ExecutorNotifierConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        initializationTimeout: Duration(seconds: native.ref.initialization_timeout_seconds),
        shutdownTimeout: Duration(seconds: native.ref.shutdown_timeout_seconds),
      );

  const ExecutorNotifierConfiguration({
    required this.ringSize,
    required this.ringFlags,
    required this.initializationTimeout,
    required this.shutdownTimeout,
  });

  ExecutorNotifierConfiguration copyWith({
    int? ringSize,
    int? ringFlags,
    Duration? initializationTimeout,
    Duration? shutdownTimeout,
    int? completionPeekCount,
  }) =>
      ExecutorNotifierConfiguration(
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        initializationTimeout: initializationTimeout ?? this.initializationTimeout,
        shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
      );
}
