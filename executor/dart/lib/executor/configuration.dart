import 'dart:ffi';

import 'package:core/core.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart';

class ExecutorModuleConfiguration implements ModuleConfiguration {
  final ExecutorSchedulerConfiguration schedulerConfiguration;

  const ExecutorModuleConfiguration(this.schedulerConfiguration);

  Pointer<executor_module_configuration> toNative(Arena arena) {
    Pointer<executor_module_configuration> native = arena();
    native.ref.scheduler_configuration = schedulerConfiguration.toNative(arena).ref;
    return native;
  }

  factory ExecutorModuleConfiguration.fromNative(executor_module_configuration native) => ExecutorModuleConfiguration(
        ExecutorSchedulerConfiguration.fromNative(native.scheduler_configuration),
      );
}

class ExecutorConfiguration {
  final int ringSize;
  final int ringFlags;

  Pointer<executor_configuration> toNative(Arena arena) {
    final native = arena<executor_configuration>();
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    return native;
  }

  factory ExecutorConfiguration.fromNative(executor_configuration native) => ExecutorConfiguration(
        ringFlags: native.ring_flags,
        ringSize: native.ring_size,
      );

  const ExecutorConfiguration({
    required this.ringSize,
    required this.ringFlags,
  });

  ExecutorConfiguration copyWith({
    int? ringSize,
    int? ringFlags,
  }) =>
      ExecutorConfiguration(
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
      );
}

class ExecutorSchedulerConfiguration {
  final int ringSize;
  final int ringFlags;
  final Duration initializationTimeout;
  final Duration shutdownTimeout;

  Pointer<executor_scheduler_configuration> toNative(Arena arena) {
    Pointer<executor_scheduler_configuration> native = arena();
    native.ref.ring_flags = ringFlags;
    native.ref.ring_size = ringSize;
    native.ref.initialization_timeout_seconds = initializationTimeout.inSeconds;
    native.ref.shutdown_timeout_seconds = shutdownTimeout.inSeconds;
    return native;
  }

  factory ExecutorSchedulerConfiguration.fromNative(executor_scheduler_configuration native) => ExecutorSchedulerConfiguration(
        ringFlags: native.ring_flags,
        ringSize: native.ring_size,
        initializationTimeout: Duration(seconds: native.initialization_timeout_seconds),
        shutdownTimeout: Duration(seconds: native.shutdown_timeout_seconds),
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
