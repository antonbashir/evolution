// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../executor/bindings.dart';

final class io_uring extends Opaque {}

final class executor_instance extends Struct {
  @Int64()
  external int callback;
  external Pointer<executor_scheduler> scheduler;
  external Pointer<io_uring> ring;
  external Pointer<Pointer<executor_completion_event>> completions;
  external executor_configuration configuration;
  @Int32()
  external int descriptor;
  @Uint32()
  external int id;
  @Int8()
  external int state;
}

@Native<Pointer<executor_instance> Function(Pointer<executor_configuration> configuration, Pointer<executor_scheduler> scheduler, Uint32 id)>(isLeaf: true)
external Pointer<executor_instance> executor_create(Pointer<executor_configuration> configuration, Pointer<executor_scheduler> scheduler, int id);

@Native<Int8 Function(Pointer<executor_instance> executor, Int64 callback)>(isLeaf: true)
external int executor_register_scheduler(Pointer<executor_instance> executor, int callback);

@Native<Int8 Function(Pointer<executor_instance> executor)>(isLeaf: true)
external int executor_unregister_scheduler(Pointer<executor_instance> executor);

@Native<Int32 Function(Pointer<executor_instance> executor)>(isLeaf: true)
external int executor_peek(Pointer<executor_instance> executor);

@Native<Void Function(Pointer<executor_instance> executor)>(isLeaf: true)
external void executor_submit(Pointer<executor_instance> executor);

@Native<Int8 Function(Pointer<executor_instance> executor)>(isLeaf: true)
external int executor_awake_begin(Pointer<executor_instance> executor);

@Native<Void Function(Pointer<executor_instance> executor, Uint32 completions)>(isLeaf: true)
external void executor_awake_complete(Pointer<executor_instance> executor, int completions);

@Native<Int8 Function(Pointer<executor_instance> executor, Int32 target_ring_fd, Pointer<executor_task> message)>(isLeaf: true)
external int executor_call_native(Pointer<executor_instance> executor, int target_ring_fd, Pointer<executor_task> message);

@Native<Int8 Function(Pointer<executor_instance> executor, Pointer<executor_task> message)>(isLeaf: true)
external int executor_callback_to_native(Pointer<executor_instance> executor, Pointer<executor_task> message);

@Native<Int8 Function(Pointer<io_uring> ring, Int32 source_ring_fd, Int32 target_ring_fd, Pointer<executor_task> message)>(isLeaf: true)
external int executor_call_dart(Pointer<io_uring> ring, int source_ring_fd, int target_ring_fd, Pointer<executor_task> message);

@Native<Int8 Function(Pointer<io_uring> ring, Int32 source_ring_fd, Pointer<executor_task> message)>(isLeaf: true)
external int executor_callback_to_dart(Pointer<io_uring> ring, int source_ring_fd, Pointer<executor_task> message);

@Native<Void Function(Pointer<executor_instance> executor)>(isLeaf: true)
external void executor_destroy(Pointer<executor_instance> executor);
