import 'dart:ffi';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';

class InteractorMessages {
  final MemoryStructurePool<interactor_message> _messages;

  InteractorMessages(MemoryModule memory) : _messages = memory.structures.register(sizeOf<interactor_message>());

  @inline
  Pointer<interactor_message> allocate() => _messages.allocate();

  @inline
  void free(Pointer<interactor_message> message) => _messages.free(message);
}
