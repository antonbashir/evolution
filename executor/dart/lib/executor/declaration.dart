import 'dart:async';
import 'dart:ffi';

import 'bindings.dart';

typedef ExecutorCallback = FutureOr<void> Function(Pointer<executor_task> notification);

abstract interface class ExecutorConsumer {
  List<ExecutorCallback> callbacks();
}

abstract interface class ExecutorProducerRegistrat {
  ExecutorMethod register(Pointer<NativeFunction<Void Function(Pointer<executor_task>)>> pointer);
}

abstract interface class ExecutorProducer {
  void initialize(ExecutorProducerRegistrat registrat);
}

abstract interface class ExecutorMethod {
  Future<Pointer<executor_task>> call(int target, Pointer<executor_task> message);
}
