import 'dart:ffi';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';

class ExecutorMessages {
  final MemoryStructurePool<executor_task> _messages;

  ExecutorMessages(MemoryModule memory) : _messages = memory.structures.register(sizeOf<executor_task>());

  @inline
  Pointer<executor_task> allocate() => _messages.allocate();

  @inline
  void free(Pointer<executor_task> message) => _messages.free(message);
}
