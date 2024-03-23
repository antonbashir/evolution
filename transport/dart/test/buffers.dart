import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:transport/transport.dart';
import 'package:transport/transport/bindings.dart';

import 'generators.dart';
import 'latch.dart';
import 'test.dart';
import 'validators.dart';

void testTcpBuffers() {
  test(
    "(tcp)",
    () => runTest(() async {
      final transport = context().transport();
      transport.initialize();
      var serverCompleter = Completer();
      var clientCompleter = Completer();
      var server = transport.servers.tcp(io.InternetAddress("0.0.0.0"), 12345, (connection) {
        connection.writeSingle(Generators.request());
        serverCompleter.complete();
      });
      var clients = await transport.clients.tcp(io.InternetAddress("127.0.0.1"), 12345);
      await clients.select().stream().listen((value) {
        value.release();
        clientCompleter.complete();
      });
      await serverCompleter.future;
      await clientCompleter.future;

      if (transport.buffers.used() != 1) throw TestFailure("actual: ${transport.buffers.used()}");

      await server.close();
      await clients.close();

      if (transport.servers.registry.serverConnections.isNotEmpty) throw TestFailure("serverConnections isNotEmpty");
      if (transport.servers.registry.servers.isNotEmpty) throw TestFailure("servers isNotEmpty");
      if (transport.clients.registry.clients.isNotEmpty) throw TestFailure("clients isNotEmpty");

      serverCompleter = Completer();
      clientCompleter = Completer();
      final clientBuffer = BytesBuilder();
      server = transport.servers.tcp(io.InternetAddress("0.0.0.0"), 12345, (connection) {
        connection.writeMany(Generators.requestsUnordered(8));
        serverCompleter.complete();
      });
      clients = await transport.clients.tcp(io.InternetAddress("127.0.0.1"), 12345);
      await clients.select().stream().listen((value) {
        clientBuffer.add(value.takeBytes());
        if (clientBuffer.length == Generators.requestsSumUnordered(8).length) {
          clientCompleter.complete();
        }
      });
      await serverCompleter.future;
      await clientCompleter.future;

      if (transport.buffers.used() != 1) throw TestFailure("actual: ${transport.buffers.used()}");

      await server.close();
      await clients.close();

      if (transport.servers.registry.serverConnections.isNotEmpty) throw TestFailure("serverConnections isNotEmpty");
      if (transport.servers.registry.servers.isNotEmpty) throw TestFailure("servers isNotEmpty");
      if (transport.clients.registry.clients.isNotEmpty) throw TestFailure("clients isNotEmpty");

      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}

void testUdpBuffers() {
  test(
    "(udp)",
    () => runTest(() async {
      final transport = context().transport();
      transport.initialize();
      var serverCompleter = Completer();
      var clientCompleter = Completer();
      var server = transport.servers.udp(io.InternetAddress("0.0.0.0"), 12345);
      server.stream().listen((value) {
        value.release();
        value.respondSingle(Generators.request());
        serverCompleter.complete();
      });
      var clients = await transport.clients.udp(io.InternetAddress("127.0.0.1"), 12346, io.InternetAddress("127.0.0.1"), 12345);
      clients.sendSingle(Generators.request());
      clients.stream().listen((value) {
        value.release();
        clientCompleter.complete();
      });
      await serverCompleter.future;
      await clientCompleter.future;

      if (transport.buffers.used() != 2) throw TestFailure("actual: ${transport.buffers.used()}");

      await server.closeServer();
      await clients.close();

      if (transport.servers.registry.serverConnections.isNotEmpty) throw TestFailure("serverConnections isNotEmpty");
      if (transport.servers.registry.servers.isNotEmpty) throw TestFailure("servers isNotEmpty");
      if (transport.clients.registry.clients.isNotEmpty) throw TestFailure("clients isNotEmpty");

      serverCompleter = Completer();
      final clientLatch = Latch(8);
      server = transport.servers.udp(io.InternetAddress("0.0.0.0"), 12345);
      server.stream().listen((value) {
        value.release();
        for (var i = 0; i < 8; i++) value.respondSingle(Generators.request());
        serverCompleter.complete();
      });
      clients = await transport.clients.udp(io.InternetAddress("127.0.0.1"), 12346, io.InternetAddress("127.0.0.1"), 12345);
      clients.sendSingle(Generators.request());
      clients.stream().listen((value) {
        value.release();
        clientLatch.countDown();
      });
      await serverCompleter.future;
      await clientLatch.done();

      if (transport.buffers.used() != 2) throw TestFailure("actual: ${transport.buffers.used()}");

      await server.closeServer();
      await clients.close();

      if (transport.servers.registry.serverConnections.isNotEmpty) throw TestFailure("serverConnections isNotEmpty");
      if (transport.servers.registry.servers.isNotEmpty) throw TestFailure("servers isNotEmpty");
      if (transport.clients.registry.clients.isNotEmpty) throw TestFailure("clients isNotEmpty");

      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}

void testFileBuffers() {
  test(
    "(file)",
    () => runTest(() async {
      final transport = context().transport();
      transport.initialize();
      final file = io.File("file");
      if (file.existsSync()) file.deleteSync();

      var fileProvider = transport.files.open(file.path, create: true);
      fileProvider.writeSingle(Generators.request());
      await fileProvider.load();

      if (transport.buffers.used() != 0) throw TestFailure("actual: ${transport.buffers.used()}");

      await fileProvider.close();

      if (transport.files.registry.files.isNotEmpty) throw TestFailure("files isNotEmpty");

      if (file.existsSync()) file.deleteSync();

      fileProvider = transport.files.open(file.path, create: true);
      fileProvider.writeMany(Generators.requestsUnordered(8));
      await fileProvider.load(blocksCount: 8);

      if (transport.buffers.used() != 0) throw TestFailure("actual: ${transport.buffers.used()}");

      await fileProvider.close();

      if (transport.files.registry.files.isNotEmpty) throw TestFailure("files isNotEmpty");

      fileProvider.delegate.deleteSync();

      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}

void testBuffersOverflow() {
  test(
    "(overflow)",
    () => runTest(
      () async {
        final transport = context().transport(configuration: TransportDefaults.transport.copyWith(memoryConfiguration: MemoryDefaults.memory.copyWith(staticBuffersCapacity: 2)));
        transport.initialize();
        transport.servers.tcp(io.InternetAddress("0.0.0.0"), 12345, (connection) {
          connection.stream().listen((value) {
            value.release();
            connection.writeSingle(Generators.response());
            connection.writeSingle(Generators.response());
            connection.writeSingle(Generators.response());
            connection.writeSingle(Generators.response());
            connection.writeSingle(Generators.response());
            connection.writeSingle(Generators.response());
          });
        });
        var clients = await transport.clients.tcp(io.InternetAddress("127.0.0.1"), 12345);
        clients.select().writeSingle(Generators.request());
        final bytes = BytesBuilder();
        final completer = Completer();
        clients.select().stream().listen((value) {
          bytes.add(value.takeBytes());
          if (bytes.length == Generators.responsesSumUnordered(6).length) {
            completer.complete();
          }
        });
        await completer.future;
        Validators.responsesSumUnordered(bytes.takeBytes(), 6);
        if (transport.buffers.used() != 2) throw TestFailure("actual: ${transport.buffers.used()}");
        await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
      },
    ),
  );
}
