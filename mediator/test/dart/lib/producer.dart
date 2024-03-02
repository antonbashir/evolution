import 'dart:ffi';

import 'package:mediator/mediator.dart';

import 'bindings.dart';

class TestNativeProducer implements MediatorProducer {
  TestNativeProducer();

  late final MediatorMethod testCallNative;
  late final MediatorMethod testThreadingCallNative;

  @override
  void initialize(MediatorProducerRegistrat registrat) {
    testCallNative = registrat.register(Pointer.fromAddress(test_call_native_address_lookup()));
    testThreadingCallNative = registrat.register(Pointer.fromAddress(test_threading_call_native_address_lookup()));
  }
}
