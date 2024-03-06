import 'dart:ffi';

import 'package:executor/executor.dart';

import 'bindings.dart';

class TestNativeProducer implements ExecutorProducer {
  TestNativeProducer();

  late final ExecutorMethod testCallNative;
  late final ExecutorMethod testThreadingCallNative;

  @override
  void initialize(ExecutorProducerRegistrat registrat) {
    testCallNative = registrat.register(Pointer.fromAddress(test_call_native_address_lookup()));
    testThreadingCallNative = registrat.register(Pointer.fromAddress(test_threading_call_native_address_lookup()));
  }
}
