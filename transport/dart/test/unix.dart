import 'dart:io';
import 'dart:typed_data';

import 'package:transport/transport.dart';
import 'package:test/test.dart';
import 'package:core/core.dart';

import 'generators.dart';
import 'latch.dart';
import 'test.dart';
import 'validators.dart';

void testUnixStreamSingle({required int index, required int clientsPool}) {
  test(
    "(single) [clients = $clientsPool]",
    () => runTest(() async {
      final transport = context().transport();
      final worker = transport;
      worker.initialize();
      final serverSocket = File(Directory.systemTemp.path + "/dart-iouring-socket_${worker.descriptor}.sock");
      if (serverSocket.existsSync()) serverSocket.deleteSync();
      worker.servers.unixStream(
        serverSocket.path,
        (connection) => connection.stream().listen(
          (event) {
            Validators.request(event.takeBytes());
            connection.writeSingle(Generators.response());
          },
        ),
      );
      final latch = Latch(clientsPool);
      final clients = await worker.clients.unixStream(serverSocket.path, configuration: TransportDefaults.unixStreamClient.copyWith(pool: clientsPool));
      clients.forEach((client) {
        client.writeSingle(Generators.request());
        client.stream().listen((event) {
          Validators.response(event.takeBytes());
          latch.countDown();
        });
      });
      await latch.done();
      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}

void testUnixStreamMany({required int index, required int clientsPool, required int count}) {
  test(
    "(many) [clients = $clientsPool, count = $count]",
    () => runTest(() async {
      final transport = context().transport();
      final worker = transport;
      worker.initialize();
      final serverSocket = File(Directory.systemTemp.path + "/dart-iouring-socket_${worker.descriptor}.sock");
      if (serverSocket.existsSync()) serverSocket.deleteSync();
      worker.servers.unixStream(
        serverSocket.path,
        (connection) {
          final serverResults = BytesBuilder();
          connection.stream().listen(
            (event) {
              serverResults.add(event.takeBytes());
              if (serverResults.length == Generators.requestsSumOrdered(count).length) {
                Validators.requestsSumOrdered(serverResults.takeBytes(), count);
                connection.writeMany(Generators.responsesOrdered(count));
              }
            },
          );
        },
      );
      final latch = Latch(clientsPool);
      final clients = await worker.clients.unixStream(serverSocket.path, configuration: TransportDefaults.unixStreamClient.copyWith(pool: clientsPool));
      clients.forEach((client) async {
        final clientResults = BytesBuilder();
        client.stream().listen(
          (event) {
            clientResults.add(event.takeBytes());
            if (clientResults.length == Generators.responsesSumOrdered(count).length) {
              Validators.responsesSumOrdered(clientResults.takeBytes(), count);
              latch.countDown();
            }
          },
        );
        client.writeMany(Generators.requestsOrdered(count));
      });
      await latch.done();
      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}
