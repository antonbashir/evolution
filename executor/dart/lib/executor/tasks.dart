import 'dart:ffi';

import 'package:memory/memory.dart';

import 'bindings.dart';

class ExecutorTasks {
  final MemoryStructurePool<executor_task> _tasks;

  ExecutorTasks() : _tasks = context().structures().register(sizeOf<executor_task>());

  @inline
  Pointer<executor_task> allocate() => _tasks.allocate();

  @inline
  void free(Pointer<executor_task> message) => _tasks.free(message);

  void destroy() => context().structures().unregister(_tasks);
}
