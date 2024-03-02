import 'dart:async';
import 'dart:ffi';

import 'package:mediator/mediator.dart';
import 'package:test/test.dart';

import 'bindings.dart';
import 'consumer.dart';
import 'producer.dart';

void testCallNative() {
  test("dart(null) <-> native(null)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());
    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final producer = mediator.producer(TestNativeProducer());
    mediator.activate();
    final call = producer.testCallNative(test_mediator_descriptor(native), mediator.messages.allocate());
    await _awaitNativeCall(native);
    final result = await call;
    mediator.messages.free(result);
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });

  test("dart(bool) <-> native(bool)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());
    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final producer = mediator.producer(TestNativeProducer());
    mediator.activate();
    final call = producer.testCallNative(test_mediator_descriptor(native), mediator.messages.allocate()..inputBool = true);
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputBool, true);
    mediator.messages.free(result);
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });

  test("dart(int) <-> native(int)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());
    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final producer = mediator.producer(TestNativeProducer());
    mediator.activate();
    final call = producer.testCallNative(test_mediator_descriptor(native), mediator.messages.allocate()..inputInt = 123);
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputInt, 123);
    mediator.messages.free(result);
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });

  test("dart(double) <-> native(double)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());
    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final producer = mediator.producer(TestNativeProducer());
    mediator.activate();
    final value = mediator.memory.doubles.allocate();
    value.value = 123.45;
    final call = producer.testCallNative(test_mediator_descriptor(native), mediator.messages.allocate()..setInputDouble(value));
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputDouble, 123.45);
    mediator.messages.free(result);
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });
}

void testCallDart() {
  test("native(null) <-> dart(null)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());

    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final completer = Completer();
    mediator.consumer(TestNativeConsumer((message) => completer.complete()));
    mediator.activate();
    test_call_dart_bool(native, mediator.descriptor, 0, true);
    await _awaitDartCall(native);
    await completer.future;
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });

  test("native(bool) <-> dart(bool)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());

    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final completer = Completer();
    mediator.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputBool, true);
        completer.complete();
      },
    ));
    mediator.activate();
    test_call_dart_bool(native, mediator.descriptor, 0, true);
    await _awaitDartCall(native);
    await completer.future;
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });

  test("native(int) <-> dart(int)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());

    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final completer = Completer();
    mediator.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputInt, 123);
        completer.complete();
      },
    ));
    mediator.activate();
    test_call_dart_int(native, mediator.descriptor, 0, 123);
    await _awaitDartCall(native);
    await completer.future;
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });

  test("native(double) <-> dart(double)", () async {
    final mediators = MediatorModule()..initialize();
    final mediator = Mediator(mediators.mediator());

    test_call_reset();
    await mediator.initialize();
    final native = test_mediator_initialize(true);
    final completer = Completer();
    mediator.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputDouble, 123.45);
        completer.complete();
      },
    ));
    mediator.activate();
    test_call_dart_double(native, mediator.descriptor, 0, 123.45);
    await _awaitDartCall(native);
    await completer.future;
    await mediators.shutdown();
    test_mediator_destroy(native, true);
  });
}

Future<void> _awaitDartCall(Pointer<mediator_native> native) async {
  while (true) {
    final result = test_call_dart_check(native);
    if (result == nullptr) {
      await Future.delayed(Duration(milliseconds: 10));
      continue;
    }
    break;
  }
}

Future<void> _awaitNativeCall(Pointer<mediator_native> native) async {
  while (!test_call_native_check(native)) await Future.delayed(Duration(milliseconds: 10));
}
