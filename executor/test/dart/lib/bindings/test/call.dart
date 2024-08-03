// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../test/bindings.dart';

final class test_object_child extends Struct {
  @Int32()
  external int field;
}

final class test_object extends Struct {
  @Int32()
  external int field;
  external test_object_child child_field;
}

@Native<Void Function()>(isLeaf: true)
external void test_call_reset();

@Native<Bool Function(Pointer<test_executor> executor)>(isLeaf: true)
external bool test_call_native_check(Pointer<test_executor> executor);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void test_call_native(Pointer<executor_task> message);

@Native<Void Function(Pointer<test_executor> executor, Int32 target, Uint64 method)>(isLeaf: true)
external void test_call_dart_null(Pointer<test_executor> executor, int target, int method);

@Native<Void Function(Pointer<test_executor> executor, Int32 target, Uint64 method, Bool value)>(isLeaf: true)
external void test_call_dart_bool(Pointer<test_executor> executor, int target, int method, bool value);

@Native<Void Function(Pointer<test_executor> executor, Int32 target, Uint64 method, Int32 value)>(isLeaf: true)
external void test_call_dart_int(Pointer<test_executor> executor, int target, int method, int value);

@Native<Void Function(Pointer<test_executor> executor, Int32 target, Uint64 method, Double value)>(isLeaf: true)
external void test_call_dart_double(Pointer<test_executor> executor, int target, int method, double value);

@Native<Pointer<executor_task> Function(Pointer<test_executor> executor)>(isLeaf: true)
external Pointer<executor_task> test_call_dart_check(Pointer<test_executor> executor);

@Native<Void Function(Pointer<executor_task> message)>(isLeaf: true)
external void test_call_dart_callback(Pointer<executor_task> message);

@Native<Int64 Function()>(isLeaf: true)
external int test_call_native_address_lookup();
