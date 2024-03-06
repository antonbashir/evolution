import 'dart:async';
import 'dart:ffi';

import 'package:executor/executor.dart';
import 'package:test/test.dart';

import 'bindings.dart';
import 'consumer.dart';
import 'producer.dart';

void testCallNative() {
  test("dart(null) <-> native(null)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());
    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final producer = executor.producer(TestNativeProducer());
    executor.activate();
    final call = producer.testCallNative(test_executor_descriptor(native), executor.messages.allocate());
    await _awaitNativeCall(native);
    final result = await call;
    executor.messages.free(result);
    await executors.shutdown();
    test_executor_destroy(native, true);
  });

  test("dart(bool) <-> native(bool)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());
    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final producer = executor.producer(TestNativeProducer());
    executor.activate();
    final call = producer.testCallNative(test_executor_descriptor(native), executor.messages.allocate()..inputBool = true);
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputBool, true);
    executor.messages.free(result);
    await executors.shutdown();
    test_executor_destroy(native, true);
  });

  test("dart(int) <-> native(int)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());
    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final producer = executor.producer(TestNativeProducer());
    executor.activate();
    final call = producer.testCallNative(test_executor_descriptor(native), executor.messages.allocate()..inputInt = 123);
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputInt, 123);
    executor.messages.free(result);
    await executors.shutdown();
    test_executor_destroy(native, true);
  });

  test("dart(double) <-> native(double)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());
    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final producer = executor.producer(TestNativeProducer());
    executor.activate();
    final value = executor.memory.doubles.allocate();
    value.value = 123.45;
    final call = producer.testCallNative(test_executor_descriptor(native), executor.messages.allocate()..setInputDouble(value));
    await _awaitNativeCall(native);
    final result = await call;
    expect(result.outputDouble, 123.45);
    executor.messages.free(result);
    await executors.shutdown();
    test_executor_destroy(native, true);
  });
}

void testCallDart() {
  test("native(null) <-> dart(null)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());

    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final completer = Completer();
    executor.consumer(TestNativeConsumer((message) => completer.complete()));
    executor.activate();
    test_call_dart_bool(native, executor.descriptor, 0, true);
    await _awaitDartCall(native);
    await completer.future;
    await executors.shutdown();
    test_executor_destroy(native, true);
  });

  test("native(bool) <-> dart(bool)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());

    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final completer = Completer();
    executor.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputBool, true);
        completer.complete();
      },
    ));
    executor.activate();
    test_call_dart_bool(native, executor.descriptor, 0, true);
    await _awaitDartCall(native);
    await completer.future;
    await executors.shutdown();
    test_executor_destroy(native, true);
  });

  test("native(int) <-> dart(int)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());

    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final completer = Completer();
    executor.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputInt, 123);
        completer.complete();
      },
    ));
    executor.activate();
    test_call_dart_int(native, executor.descriptor, 0, 123);
    await _awaitDartCall(native);
    await completer.future;
    await executors.shutdown();
    test_executor_destroy(native, true);
  });

  test("native(double) <-> dart(double)", () async {
    final executors = ExecutorModule()..initialize();
    final executor = Executor(executors.executor());

    test_call_reset();
    await executor.initialize();
    final native = test_executor_initialize(true);
    final completer = Completer();
    executor.consumer(TestNativeConsumer(
      (message) {
        expect(message.inputDouble, 123.45);
        completer.complete();
      },
    ));
    executor.activate();
    test_call_dart_double(native, executor.descriptor, 0, 123.45);
    await _awaitDartCall(native);
    await completer.future;
    await executors.shutdown();
    test_executor_destroy(native, true);
  });
}

Future<void> _awaitDartCall(Pointer<executor_native> native) async {
  while (true) {
    final result = test_call_dart_check(native);
    if (result == nullptr) {
      await Future.delayed(Duration(milliseconds: 10));
      continue;
    }
    break;
  }
}

Future<void> _awaitNativeCall(Pointer<executor_native> native) async {
  while (!test_call_native_check(native)) await Future.delayed(Duration(milliseconds: 10));
}
