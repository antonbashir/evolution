import 'dart:async';
import 'dart:ffi';

import 'package:interactor/interactor.dart';
import 'package:test/test.dart';

import 'bindings.dart';
import 'consumer.dart';
import 'producer.dart';

void testCallNative() {
  test("dart(null) <-> native(null)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());
    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final producer = interactor.producer(TestNativeProducer());
    interactor.activate();
    final call = producer.testCallNative(test_interactor_descriptor(native), interactor.messages.allocate());
    await _awaitNativeCall(native);
    final result = await call;
    interactor.messages.free(result);
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });

  test("dart(bool) <-> native(bool)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());
    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final producer = interactor.producer(TestNativeProducer());
    interactor.activate();
    final call = producer.testCallNative(test_interactor_descriptor(native), interactor.messages.allocate()..inputBool = true);
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputBool, true);
    interactor.messages.free(result);
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });

  test("dart(int) <-> native(int)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());
    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final producer = interactor.producer(TestNativeProducer());
    interactor.activate();
    final call = producer.testCallNative(test_interactor_descriptor(native), interactor.messages.allocate()..inputInt = 123);
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputInt, 123);
    interactor.messages.free(result);
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });

  test("dart(double) <-> native(double)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());
    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final producer = interactor.producer(TestNativeProducer());
    interactor.activate();
    final value = interactor.memory.doubles.allocate();
    value.value = 123.45;
    final call = producer.testCallNative(test_interactor_descriptor(native), interactor.messages.allocate()..setInputDouble(value));
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputDouble, 123.45);
    interactor.messages.free(result);
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });
}

void testCallDart() {
  test("native(null) <-> dart(null)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());

    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final completer = Completer();
    interactor.consumer(TestNativeConsumer((message) => completer.complete()));
    interactor.activate();
    test_call_dart_bool(native, interactor.descriptor, 0, true);
    await _awaitDartCall(native);
    await completer.future;
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });

  test("native(bool) <-> dart(bool)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());

    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final completer = Completer();
    interactor.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputBool, true);
        completer.complete();
      },
    ));
    interactor.activate();
    test_call_dart_bool(native, interactor.descriptor, 0, true);
    await _awaitDartCall(native);
    await completer.future;
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });

  test("native(int) <-> dart(int)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());

    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final completer = Completer();
    interactor.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputInt, 123);
        completer.complete();
      },
    ));
    interactor.activate();
    test_call_dart_int(native, interactor.descriptor, 0, 123);
    await _awaitDartCall(native);
    await completer.future;
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });

  test("native(double) <-> dart(double)", () async {
    final interactors = InteractorModule();
    final interactor = Interactor(interactors.interactor());

    test_call_reset();
    await interactor.initialize();
    final native = test_interactor_initialize(true);
    final completer = Completer();
    interactor.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputDouble, 123.45);
        completer.complete();
      },
    ));
    interactor.activate();
    test_call_dart_double(native, interactor.descriptor, 0, 123.45);
    await _awaitDartCall(native);
    await completer.future;
    await interactors.shutdown();
    test_interactor_destroy(native, true);
  });
}

Future<void> _awaitDartCall(Pointer<interactor_native> native) async {
  while (true) {
    final result = test_call_dart_check(native);
    if (result == nullptr) {
      await Future.delayed(Duration(milliseconds: 10));
      continue;
    }
    break;
  }
}

Future<void> _awaitNativeCall(Pointer<interactor_native> native) async {
  while (!test_call_native_check(native)) await Future.delayed(Duration(milliseconds: 10));
}
