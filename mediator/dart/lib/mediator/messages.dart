import 'dart:ffi';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';

class MediatorMessages {
  final MemoryStructurePool<mediator_message> _messages;

  MediatorMessages(MemoryModule memory) : _messages = memory.structures.register(sizeOf<mediator_message>());

  @inline
  Pointer<mediator_message> allocate() => _messages.allocate();

  @inline
  void free(Pointer<mediator_message> message) => _messages.free(message);
}
