import 'dart:io';

import 'package:core/core.dart';
import 'package:reactive/reactive/frame.dart';
import 'package:transport/transport.dart';
import 'package:reactive/reactive.dart';
import 'package:test/test.dart';
import 'latch.dart';
import 'test.dart';

void keepalive() {
  test(
    'pass',
    timeout: Timeout(Duration(seconds: 60)),
    () => runTest(() async {
      final latch = Latch(2);
      var delta = DateTime.now();

      void _trace(frame) {
        if (frame is KeepAliveFrame) {
          latch.notify();
          if (latch.count == 2) {
            expect(true, DateTime.now().millisecondsSinceEpoch - delta.millisecondsSinceEpoch > Duration(seconds: 5).inMilliseconds);
          }
        }
      }

      final transport = context().transport();

      transport.initialize();
      final reactive = ReactiveTransport(transport, ReactiveTransportDefaults.module.copyWith(tracer: _trace));

      reactive.serve(
        InternetAddress.anyIPv4,
        12345,
        (subscriber) => subscriber.subscribe("channel"),
      );

      reactive.connect(
        InternetAddress.loopbackIPv4,
        12345,
        setupConfiguration: ReactiveTransportDefaults.setup.copyWith(keepAliveInterval: Duration(seconds: 5)),
        (subscriber) => subscriber.subscribe("channel"),
      );

      await latch.done();

      await reactive.shutdown(transport: true);
    }),
  );

  test(
    'fail',
    timeout: Timeout(Duration(seconds: 60)),
    () => runTest(() async {
      final latch = Latch(2);

      final transport = context().transport();

      transport.initialize();
      final reactive = ReactiveTransport(transport, ReactiveTransportDefaults.module);

      reactive.serve(
        InternetAddress.anyIPv4,
        12345,
        onShutdown: () => latch.notify(),
        (subscriber) {
          subscriber.subscribe("channel");
        },
      );

      reactive.connect(
        InternetAddress.loopbackIPv4,
        12345,
        onShutdown: () => latch.notify(),
        setupConfiguration: ReactiveTransportDefaults.setup.copyWith(keepAliveInterval: Duration(seconds: 10), keepAliveMaxLifetime: Duration(seconds: 5)),
        (subscriber) {
          subscriber.subscribe("channel");
        },
      );

      await latch.done();

      await reactive.shutdown(transport: true);
    }),
  );
}
