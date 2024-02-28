import 'dart:ffi';

import 'bindings.dart';

class InteractorModuleConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int ringSize;
  final int ringFlags;
  final double delayRandomizationFactor;
  final int cqePeekCount;
  final int cqeWaitCount;
  final Duration cqeWaitTimeout;
  final Duration baseDelay;
  final Duration maxDelay;
  final int memorySlabSize;
  final int memoryPreallocationSize;
  final int memoryQuotaSize;

  Pointer<interactor_module_dart_configuration> toNative(Pointer<interactor_module_dart_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.base_delay_micros = baseDelay.inMicroseconds;
    native.ref.max_delay_micros = maxDelay.inMicroseconds;
    native.ref.delay_randomization_factor = delayRandomizationFactor;
    native.ref.cqe_peek_count = cqePeekCount;
    native.ref.cqe_wait_count = cqeWaitCount;
    native.ref.cqe_wait_timeout_millis = cqeWaitTimeout.inMilliseconds;
    native.ref.slab_size = memorySlabSize;
    native.ref.preallocation_size = memoryPreallocationSize;
    native.ref.quota_size = memoryQuotaSize;
    return native;
  }

  factory InteractorModuleConfiguration.fromNative(Pointer<interactor_module_dart_configuration> native) => InteractorModuleConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        staticBufferSize: native.ref.static_buffer_size,
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        baseDelay: Duration(microseconds: native.ref.base_delay_micros),
        maxDelay: Duration(microseconds: native.ref.max_delay_micros),
        delayRandomizationFactor: native.ref.delay_randomization_factor,
        cqePeekCount: native.ref.cqe_peek_count,
        cqeWaitCount: native.ref.cqe_wait_count,
        cqeWaitTimeout: Duration(milliseconds: native.ref.cqe_wait_timeout_millis),
        memorySlabSize: native.ref.slab_size,
        memoryPreallocationSize: native.ref.preallocation_size,
        memoryQuotaSize: native.ref.quota_size,
      );

  const InteractorModuleConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.ringSize,
    required this.ringFlags,
    required this.delayRandomizationFactor,
    required this.baseDelay,
    required this.maxDelay,
    required this.cqePeekCount,
    required this.cqeWaitCount,
    required this.cqeWaitTimeout,
    required this.memorySlabSize,
    required this.memoryPreallocationSize,
    required this.memoryQuotaSize,
  });

  InteractorModuleConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? ringSize,
    int? ringFlags,
    Duration? timeoutCheckerPeriod,
    double? delayRandomizationFactor,
    Duration? baseDelay,
    Duration? maxDelay,
    int? cqePeekCount,
    int? cqeWaitCount,
    Duration? cqeWaitTimeout,
    int? memorySlabSize,
    int? memoryPreallocationSize,
    int? memoryQuotaSize,
  }) =>
      InteractorModuleConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        delayRandomizationFactor: delayRandomizationFactor ?? this.delayRandomizationFactor,
        baseDelay: baseDelay ?? this.baseDelay,
        maxDelay: maxDelay ?? this.maxDelay,
        cqePeekCount: cqePeekCount ?? this.cqePeekCount,
        cqeWaitCount: cqeWaitCount ?? this.cqeWaitCount,
        cqeWaitTimeout: cqeWaitTimeout ?? this.cqeWaitTimeout,
        memorySlabSize: memorySlabSize ?? this.memorySlabSize,
        memoryPreallocationSize: memoryPreallocationSize ?? this.memoryPreallocationSize,
        memoryQuotaSize: memoryQuotaSize ?? this.memoryQuotaSize,
      );
}
