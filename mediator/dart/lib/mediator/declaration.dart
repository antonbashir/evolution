import 'dart:async';
import 'dart:ffi';

import 'bindings.dart';

typedef MediatorCallback = FutureOr<void> Function(Pointer<mediator_message> notification);

abstract interface class MediatorConsumer {
  List<MediatorCallback> callbacks();
}

abstract interface class MediatorProducerRegistrat {
  MediatorMethod register(Pointer<NativeFunction<Void Function(Pointer<mediator_message>)>> pointer);
}

abstract interface class MediatorProducer {
  void initialize(MediatorProducerRegistrat registrat);
}

abstract interface class MediatorMethod {
  Future<Pointer<mediator_message>> call(int target, Pointer<mediator_message> message);
}
