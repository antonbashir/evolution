import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:reactive/reactive.dart';
import 'package:test/test.dart';
import 'package:transport/transport.dart';

import 'latch.dart';
import 'test.dart';

void backpressure() {
  test(
    "4 + 2 requests -> infinity response",
    () => runTest(() async {
      final latch = Latch(6);
      final transport = context().transport();
      transport.initialize();
      final reactive = ReactiveTransport(transport, ReactiveTransportDefaults.module);
      late final Timer timer;
      reactive.serve(
        InternetAddress.anyIPv4,
        12345,
        (subscriber) {
          subscriber.subscribe(
            "channel",
            onSubscribe: (producer) {
              timer = Timer.periodic(Duration(milliseconds: 500), (timer) => producer.payload("data"));
            },
          );
        },
      );

      reactive.connect(
        InternetAddress.loopbackIPv4,
        12345,
        (subscriber) {
          subscriber.subscribe(
            "channel",
            onSubscribe: (producer) {
              producer.request(4);
            },
            onPayload: (payload, producer) async {
              latch.notify();
              if (latch.count == 4) {
                await Future.delayed(Duration(seconds: 2));
                producer.request(2);
              }
            },
          );
        },
      );

      await latch.done();

      await Future.delayed(Duration(seconds: 2));

      expect(latch.count, 6);

      await reactive.shutdown(transport: true);

      timer.cancel();
    }),
  );
}
