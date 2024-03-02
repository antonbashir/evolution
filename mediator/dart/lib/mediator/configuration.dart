import 'dart:ffi';

import 'bindings.dart';

class MediatorConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int ringSize;
  final int ringFlags;
  final int completionPeekCount;
  final int completionWaitCount;
  final Duration completionWaitTimeout;
  final Duration maximumWakingTime;
  final int memorySlabSize;
  final int memoryPreallocationSize;
  final int memoryQuotaSize;

  Pointer<mediator_dart_configuration> toNative(Pointer<mediator_dart_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.maximum_waking_time_millis = maximumWakingTime.inMilliseconds;
    native.ref.completion_peek_count = completionPeekCount;
    native.ref.completion_wait_count = completionWaitCount;
    native.ref.completion_wait_timeout_millis = completionWaitTimeout.inMilliseconds;
    native.ref.slab_size = memorySlabSize;
    native.ref.preallocation_size = memoryPreallocationSize;
    native.ref.quota_size = memoryQuotaSize;
    return native;
  }

  factory MediatorConfiguration.fromNative(Pointer<mediator_dart_configuration> native) => MediatorConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        staticBufferSize: native.ref.static_buffer_size,
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        maximumWakingTime: Duration(milliseconds: native.ref.maximum_waking_time_millis),
        completionPeekCount: native.ref.completion_peek_count,
        completionWaitCount: native.ref.completion_wait_count,
        completionWaitTimeout: Duration(milliseconds: native.ref.completion_wait_timeout_millis),
        memorySlabSize: native.ref.slab_size,
        memoryPreallocationSize: native.ref.preallocation_size,
        memoryQuotaSize: native.ref.quota_size,
      );

  const MediatorConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.ringSize,
    required this.ringFlags,
    required this.maximumWakingTime,
    required this.completionPeekCount,
    required this.completionWaitCount,
    required this.completionWaitTimeout,
    required this.memorySlabSize,
    required this.memoryPreallocationSize,
    required this.memoryQuotaSize,
  });

  MediatorConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? ringSize,
    int? ringFlags,
    Duration? timeoutCheckerPeriod,
    Duration? maximumWakingTime,
    int? completionPeekCount,
    int? completionWaitCount,
    Duration? completionWaitTimeout,
    int? memorySlabSize,
    int? memoryPreallocationSize,
    int? memoryQuotaSize,
  }) =>
      MediatorConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        maximumWakingTime: maximumWakingTime ?? this.maximumWakingTime,
        completionPeekCount: completionPeekCount ?? this.completionPeekCount,
        completionWaitCount: completionWaitCount ?? this.completionWaitCount,
        completionWaitTimeout: completionWaitTimeout ?? this.completionWaitTimeout,
        memorySlabSize: memorySlabSize ?? this.memorySlabSize,
        memoryPreallocationSize: memoryPreallocationSize ?? this.memoryPreallocationSize,
        memoryQuotaSize: memoryQuotaSize ?? this.memoryQuotaSize,
      );
}

class MediatorNotifierConfiguration {
  final int ringSize;
  final int ringFlags;
  final Duration initializationTimeout;
  final Duration shutdownTimeout;

  Pointer<mediator_dart_notifier_configuration> toNative(Pointer<mediator_dart_notifier_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.initialization_timeout_seconds = initializationTimeout.inSeconds;
    native.ref.shutdown_timeout_seconds = shutdownTimeout.inSeconds;
    return native;
  }

  factory MediatorNotifierConfiguration.fromNative(Pointer<mediator_dart_notifier_configuration> native) => MediatorNotifierConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        initializationTimeout: Duration(seconds: native.ref.initialization_timeout_seconds),
        shutdownTimeout: Duration(seconds: native.ref.shutdown_timeout_seconds),
      );

  const MediatorNotifierConfiguration({
    required this.ringSize,
    required this.ringFlags,
    required this.initializationTimeout,
    required this.shutdownTimeout,
  });

  MediatorNotifierConfiguration copyWith({
    int? ringSize,
    int? ringFlags,
    Duration? initializationTimeout,
    Duration? shutdownTimeout,
  }) =>
      MediatorNotifierConfiguration(
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        initializationTimeout: initializationTimeout ?? this.initializationTimeout,
        shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
      );
}
