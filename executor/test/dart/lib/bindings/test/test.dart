// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../test/bindings.dart';

final class table_native_callbacks_t extends Opaque {}

final class test_executor extends Struct {
  external Pointer<io_uring> ring;
  @Int32()
  external int descriptor;
  external Pointer<table_native_callbacks_t> callbacks;
}

@Native<Pointer<test_executor> Function(Bool initialize_memory)>(isLeaf: true)
external Pointer<test_executor> test_executor_initialize(bool initialize_memory);

@Native<Void Function(Pointer<test_executor> executor, Bool initialize_memory)>(isLeaf: true)
external void test_executor_destroy(Pointer<test_executor> executor, bool initialize_memory);

@Native<Pointer<executor_task> Function()>(isLeaf: true)
external Pointer<executor_task> test_allocate_message();

@Native<Pointer<Double> Function()>(isLeaf: true)
external Pointer<Double> test_allocate_double();
