import 'dart:ffi';

import 'package:interactor/interactor.dart';

import 'bindings.dart';

class TestNativeProducer implements InteractorProducer {
  TestNativeProducer();

  late final InteractorMethod testCallNative;
  late final InteractorMethod testThreadingCallNative;

  @override
  void initialize(InteractorProducerRegistrat registrat) {
    testCallNative = registrat.register(Pointer.fromAddress(test_call_native_address_lookup()));
    testThreadingCallNative = registrat.register(Pointer.fromAddress(test_threading_call_native_address_lookup()));
  }
}
