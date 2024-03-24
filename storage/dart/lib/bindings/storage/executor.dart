// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../storage/bindings.dart';

final class storage_executor_configuration extends Struct {
  @Size()
  external int executor_ring_size;
  external Pointer<storage_configuration> configuration;
  @Uint32()
  external int executor_id;
}

@Native<Int32 Function(Pointer<storage_executor_configuration> configuration)>(isLeaf: true)
external int storage_executor_initialize(Pointer<storage_executor_configuration> configuration);

@Native<Void Function(Pointer<storage_executor_configuration> configuration)>(isLeaf: true)
external void storage_executor_start(Pointer<storage_executor_configuration> configuration);

@Native<Void Function()>(isLeaf: true)
external void storage_executor_stop();

@Native<Void Function()>(isLeaf: true)
external void storage_executor_destroy();

@Native<Int32 Function()>(isLeaf: true)
external int storage_executor_descriptor();
