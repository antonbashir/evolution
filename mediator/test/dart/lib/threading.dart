import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:mediator/mediator.dart';
import 'package:mediator_test/consumer.dart';
import 'package:mediator_test/producer.dart';
import 'package:test/test.dart';

import 'bindings.dart';

void testThreadingNative() {
  test("[isolates]dart(bytes) <-> [threads]native(bytes)", () async {
    final mediator = MediatorModule();
    final messages = 16;
    final isolates = 4;
    final threads = 8;

    if (!test_threading_initialize(threads, isolates, messages * isolates)) {
      fail("native thread failed ");
    }

    final spawnedIsolates = <Future<Isolate>>[];
    final exitPorts = <ReceivePort>[];
    final errorPorts = <ReceivePort>[];

    for (var isolate = 0; isolate < isolates; isolate++) {
      final exitPort = ReceivePort();
      exitPorts.add(exitPort);

      final errorPort = ReceivePort();
      errorPorts.add(errorPort);

      final isolate = Isolate.spawn<List<dynamic>>(
        _callNativeIsolate,
        onError: errorPort.sendPort,
        [messages, threads, mediator.mediator(), exitPort.sendPort],
      );

      spawnedIsolates.add(isolate);
    }

    errorPorts.forEach(
      (element) => element.listen((message) {
        exitPorts.forEach((port) => port.close());
        errorPorts.forEach((port) => port.close());
        fail(message.toString());
      }),
    );

    await Future.wait(spawnedIsolates);
    while (test_threading_call_native_check() != messages * isolates * threads) await Future.delayed(Duration(milliseconds: 1));
    await Future.wait(exitPorts.map((port) => port.first));

    exitPorts.forEach((port) => port.close());
    errorPorts.forEach((port) => port.close());

    test_threading_destroy();
    await mediator.shutdown();
  });
}

void testThreadingDart() {
  test("[threads]native(bytes) <-> [isolates]dart(bytes)", () async {
    final mediator = MediatorModule();
    final messages = 16;
    final isolates = 4;
    final threads = 8;

    if (!test_threading_initialize(threads, isolates, messages * isolates)) {
      fail("native thread failed ");
    }

    final spawnedIsolates = <Future<Isolate>>[];
    final descriptorPorts = <ReceivePort>[];
    final exitPorts = <ReceivePort>[];
    final errorPorts = <ReceivePort>[];

    for (var isolate = 0; isolate < isolates; isolate++) {
      final descriptorPort = ReceivePort();
      descriptorPorts.add(descriptorPort);

      final exitPort = ReceivePort();
      exitPorts.add(exitPort);

      final errorPort = ReceivePort();
      errorPorts.add(errorPort);

      final isolate = Isolate.spawn<List<dynamic>>(
        _callDartIsolate,
        onError: errorPort.sendPort,
        [messages * threads, mediator.mediator(), descriptorPort.sendPort, exitPort.sendPort],
      );

      spawnedIsolates.add(isolate);
    }

    errorPorts.forEach(
      (element) => element.listen((message) {
        exitPorts.forEach((port) => port.close());
        errorPorts.forEach((port) => port.close());
        fail(message.toString());
      }),
    );

    await Future.wait(spawnedIsolates);
    final descriptors = (await Future.wait(descriptorPorts.map((port) => port.first))).map((descriptor) => descriptor as int).toList();
    final Pointer<Int32> descriptorsNative = calloc(descriptors.length * sizeOf<Int32>());
    descriptors.forEachIndexed((index, element) => descriptorsNative[index] = element);
    test_threading_prepare_call_dart_bytes(descriptorsNative, descriptors.length);

    while (test_threading_call_dart_check() != messages * threads * isolates) await Future.delayed(Duration(milliseconds: 1));
    await Future.wait(exitPorts.map((port) => port.first));

    exitPorts.forEach((port) => port.close());
    errorPorts.forEach((port) => port.close());

    test_threading_destroy();
    await mediator.shutdown();
  });
}

Future<void> _callNativeIsolate(List<dynamic> input) async {
  final messages = input[0];
  final threads = input[1];
  final calls = <Future<Pointer<mediator_message>>>[];
  final worker = Mediator(input[2]);
  await worker.initialize();
  final producer = worker.producer(TestNativeProducer());
  worker.activate();
  final descriptors = test_threading_mediator_descriptors();
  for (var threadId = 0; threadId < threads; threadId++) {
    final descriptor = descriptors + threadId;
    if (descriptor == nullptr) {
      fail("descriptor is null");
    }
    for (var messageId = 0; messageId < messages; messageId++) {
      final message = worker.messages.allocate();
      message.inputInt = 41;
      calls.add(producer.testThreadingCallNative(descriptor.value, message));
    }
  }
  (await Future.wait(calls)).forEach((result) {
    if (result.outputInt != 41) {
      throw TestFailure("outputInt != 41");
    }
    worker.messages.free(result);
  });
  input[3].send(null);
}

Future<void> _callDartIsolate(List<dynamic> input) async {
  final messages = input[0];
  final worker = Mediator(input[1]);
  await worker.initialize();
  var count = 0;
  final completer = Completer();
  worker.consumer(TestNativeConsumer(
    (notification) {
      if (!ListEquality().equals(notification.inputBytes, [1, 2, 3])) {
        completer.completeError(TestFailure("inputBytes != ${[1, 2, 3]}. ${notification.inputSize}: ${notification.inputBytes}"));
        return;
      }
      if (++count == messages) {
        completer.complete();
        return;
      }
    },
  ));
  worker.activate();

  input[2].send(worker.descriptor);

  await completer.future;

  input[3].send(null);
}
