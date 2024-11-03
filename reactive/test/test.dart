import 'dart:async';

import 'package:executor/executor.dart';
import 'package:memory/memory.dart';
import 'package:test/test.dart';
import 'package:transport/transport.dart';

import 'backpressure.dart';
import 'custom.dart';
import 'errors.dart';
import 'fragmentation.dart';
import 'interaction.dart';
import 'keepalive.dart';
import 'lease.dart';
import 'shutdown.dart';

FutureOr<void> runTest(FutureOr<void> Function() test, {List<Module>? overrides}) {
  system().environment.debug = false;
  return launch(() => overrides ?? [CoreModule(), MemoryModule(), ExecutorModule(), TransportModule()], test);
}

void main() {
  group("[interaction]", interaction);
  group("[fragmentation]", fragmentation);
  group("[errors]", errors);
  group("[custom]", custom);
  group("[backpressure]", backpressure);
  group("[keepalive]", keepalive);
  group("[lease]", lease);
  group("[shutdown]", shutdown);
}
