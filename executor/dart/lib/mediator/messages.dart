import 'dart:ffi';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';

class ExecutorMessages {
  final MemoryStructurePool<executor_message> _messages;

  ExecutorMessages(MemoryModule memory) : _messages = memory.structures.register(sizeOf<executor_message>());

  @inline
  Pointer<executor_message> allocate() => _messages.allocate();

  @inline
  void free(Pointer<executor_message> message) => _messages.free(message);
}
