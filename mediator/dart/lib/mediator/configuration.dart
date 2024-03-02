import 'dart:ffi';

import 'bindings.dart';

class MediatorConfiguration {
  final int staticBuffersCapacity;
  final int staticBufferSize;
  final int ringSize;
  final int ringFlags;
  final int memorySlabSize;
  final int memoryPreallocationSize;
  final int memoryQuotaSize;
  final bool trace;

  Pointer<mediator_dart_configuration> toNative(Pointer<mediator_dart_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.static_buffer_size = staticBufferSize;
    native.ref.static_buffers_capacity = staticBuffersCapacity;
    native.ref.slab_size = memorySlabSize;
    native.ref.preallocation_size = memoryPreallocationSize;
    native.ref.quota_size = memoryQuotaSize;
    native.ref.trace = trace;
    return native;
  }

  factory MediatorConfiguration.fromNative(Pointer<mediator_dart_configuration> native) => MediatorConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        staticBufferSize: native.ref.static_buffer_size,
        staticBuffersCapacity: native.ref.static_buffers_capacity,
        memorySlabSize: native.ref.slab_size,
        memoryPreallocationSize: native.ref.preallocation_size,
        memoryQuotaSize: native.ref.quota_size,
        trace: native.ref.trace,
      );

  const MediatorConfiguration({
    required this.staticBuffersCapacity,
    required this.staticBufferSize,
    required this.ringSize,
    required this.ringFlags,
    required this.memorySlabSize,
    required this.memoryPreallocationSize,
    required this.memoryQuotaSize,
    required this.trace,
  });

  MediatorConfiguration copyWith({
    int? staticBuffersCapacity,
    int? staticBufferSize,
    int? ringSize,
    int? ringFlags,
    Duration? timeoutCheckerPeriod,
    int? memorySlabSize,
    int? memoryPreallocationSize,
    int? memoryQuotaSize,
    bool? trace,
  }) =>
      MediatorConfiguration(
        staticBuffersCapacity: staticBuffersCapacity ?? this.staticBuffersCapacity,
        staticBufferSize: staticBufferSize ?? this.staticBufferSize,
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        memorySlabSize: memorySlabSize ?? this.memorySlabSize,
        memoryPreallocationSize: memoryPreallocationSize ?? this.memoryPreallocationSize,
        memoryQuotaSize: memoryQuotaSize ?? this.memoryQuotaSize,
        trace: trace ?? this.trace,
      );
}

class MediatorNotifierConfiguration {
  final int ringSize;
  final int ringFlags;
  final Duration initializationTimeout;
  final Duration shutdownTimeout;
  final bool trace;

  Pointer<mediator_dart_notifier_configuration> toNative(Pointer<mediator_dart_notifier_configuration> native) {
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.initialization_timeout_seconds = initializationTimeout.inSeconds;
    native.ref.shutdown_timeout_seconds = shutdownTimeout.inSeconds;
    native.ref.trace = trace;
    return native;
  }

  factory MediatorNotifierConfiguration.fromNative(Pointer<mediator_dart_notifier_configuration> native) => MediatorNotifierConfiguration(
        ringFlags: native.ref.ring_flags,
        ringSize: native.ref.ring_size,
        initializationTimeout: Duration(seconds: native.ref.initialization_timeout_seconds),
        shutdownTimeout: Duration(seconds: native.ref.shutdown_timeout_seconds),
        trace: native.ref.trace,
      );

  const MediatorNotifierConfiguration({
    required this.ringSize,
    required this.ringFlags,
    required this.initializationTimeout,
    required this.shutdownTimeout,
    required this.trace,
  });

  MediatorNotifierConfiguration copyWith({
    int? ringSize,
    int? ringFlags,
    Duration? initializationTimeout,
    Duration? shutdownTimeout,
    bool? trace,
    int? completionPeekCount,
  }) =>
      MediatorNotifierConfiguration(
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
        initializationTimeout: initializationTimeout ?? this.initializationTimeout,
        shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
        trace: trace ?? this.trace,
      );
}
