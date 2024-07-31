// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../test/bindings.dart';

@Native<Bool Function(Int32 thread_count, Int32 isolates_count, Int32 per_thread_messages_count)>(isLeaf: true)
external bool test_threading_initialize(int thread_count, int isolates_count, int per_thread_messages_count);

@Native<Pointer<Int> Function()>(isLeaf: true)
external Pointer<Int> test_threading_executor_descriptors();

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void test_threading_call_native(Pointer<executor_task> message);

@Native<Int32 Function()>(isLeaf: true)
external int test_threading_call_native_check();

@Native<Void Function(Pointer<Int32> targets, Int32 count)>(isLeaf: true)
external void test_threading_prepare_call_dart_bytes(Pointer<Int32> targets, int count);

@Native<Int32 Function()>(isLeaf: true)
external int test_threading_call_dart_check();

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void test_threading_call_dart_callback(Pointer<executor_task> message);

@Native<Void Function()>(isLeaf: true)
external void test_threading_destroy();

@Native<Int64 Function()>(isLeaf: true)
external int test_threading_call_native_address_lookup();
