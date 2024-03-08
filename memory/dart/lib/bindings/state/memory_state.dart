import 'dart:ffi';

import '../include/memory.dart';
import '../include/memory_configuration.dart';
import '../include/memory_io_buffers.dart';
import '../include/memory_static_buffers.dart';

final class memory_state extends Struct {
  external Pointer<memory_static_buffers> static_buffers;
  external Pointer<memory_io_buffers> io_buffers;
  external Pointer<memory> memory_instance;
}

@Native<Pointer<memory_state> Function()>(symbol: 'memory_state_construct', assetId: 'memory-bindings', isLeaf: true)
external Pointer<memory_state> memory_state_construct();

@Native<Void Function(Pointer<memory_state>)>(symbol: 'memory_state_destruct', assetId: 'memory-bindings', isLeaf: true)
external void memory_state_destruct(Pointer<memory_state> memory);

@Native<Int32 Function(Pointer<memory_state>, Pointer<memory_configuration>)>(symbol: 'memory_state_create', assetId: 'memory-bindings', isLeaf: true)
external int memory_state_create(Pointer<memory_state> memory, Pointer<memory_configuration> configuration);

@Native<Void Function(Pointer<memory_state>)>(symbol: 'memory_state_destroy', assetId: 'memory-bindings', isLeaf: true)
external void memory_state_destroy(Pointer<memory_state> memory);
