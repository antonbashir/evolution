import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:memory/memory.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'bindings.dart';
import 'consumer.dart';
import 'producer.dart';

Future<void> _execute(FutureOr<void> Function() test) => launch(
      [
        CoreModule.new,
        MemoryModule.new,
        ExecutorModule.new,
      ],
      () async {
        SystemLibrary.loadByPath("${Directory(path.dirname(Platform.script.toFilePath())).parent.path}/assets/libexecutor_test.so", "executor_test");
        await test();
      },
    );

void testCallNative() {
  test(
    "dart(null) <-> native(null)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
      final native = test_executor_initialize(true);
      final producer = executor.producer(TestNativeProducer());
      executor.activate();
      final call = producer.testCallNative(native.ref.descriptor, executor.tasks.allocate());
      await _awaitNativeCall(native);
      final result = await call;
      executor.tasks.free(result);
      test_executor_destroy(native, true);
    }),
  );

  test(
    "dart(bool) <-> native(bool)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
      final native = test_executor_initialize(true);
      final producer = executor.producer(TestNativeProducer());
      executor.activate();
      final call = producer.testCallNative(native.ref.descriptor, executor.tasks.allocate()..inputBool = true);
      await _awaitNativeCall(native);
      final result = await call;
      expect(result.outputBool, true);
      executor.tasks.free(result);
      test_executor_destroy(native, true);
    }),
  );

  test(
    "dart(int) <-> native(int)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
      final native = test_executor_initialize(true);
      final producer = executor.producer(TestNativeProducer());
      executor.activate();
      final call = producer.testCallNative(native.ref.descriptor, executor.tasks.allocate()..inputInt = 123);
      await _awaitNativeCall(native);
      final result = await call;
      expect(result.outputInt, 123);
      executor.tasks.free(result);
      test_executor_destroy(native, true);
    }),
  );

  test(
    "dart(double) <-> native(double)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
      final native = test_executor_initialize(true);
      final producer = executor.producer(TestNativeProducer());
      executor.activate();
      final value = context().doubles().allocate();
      value.value = 123.45;
      final call = producer.testCallNative(native.ref.descriptor, executor.tasks.allocate()..setInputDouble(value));
      await _awaitNativeCall(native);
      final result = await call;
      expect(result.outputDouble, 123.45);
      executor.tasks.free(result);
      test_executor_destroy(native, true);
    }),
  );
}

void testCallDart() {
  test(
    "native(null) <-> dart(null)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
      final native = test_executor_initialize(true);
      final completer = Completer();
      executor.consumer(TestNativeConsumer((message) => completer.complete()));
      executor.activate();
      test_call_dart_bool(native, executor.descriptor, 0, true);
      await _awaitDartCall(native);
      await completer.future;
      test_executor_destroy(native, true);
    }),
  );

  test(
    "native(bool) <-> dart(bool)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
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
      test_executor_destroy(native, true);
    }),
  );

  test(
    "native(int) <-> dart(int)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
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
      test_executor_destroy(native, true);
    }),
  );

  test(
    "native(double) <-> dart(double)",
    () => _execute(() async {
      final executor = context().broker();
      test_call_reset();
      executor.initialize();
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
      test_executor_destroy(native, true);
    }),
  );
}

Future<void> _awaitDartCall(Pointer<test_executor> native) async {
  while (true) {
    final result = test_call_dart_check(native);
    if (result == nullptr) {
      await Future.delayed(Duration(milliseconds: 10));
      continue;
    }
    break;
  }
}

Future<void> _awaitNativeCall(Pointer<test_executor> native) async {
  while (!test_call_native_check(native)) await Future.delayed(Duration(milliseconds: 10));
}
