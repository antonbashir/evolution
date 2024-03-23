import 'dart:io' as io;
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:transport/transport.dart';
import 'package:test/test.dart';

import 'generators.dart';
import 'latch.dart';
import 'test.dart';
import 'validators.dart';

void testTcpSingle({required int index, required int clientsPool}) {
  test(
    "(single) [clients = $clientsPool]",
    () => runTest(() async {
      final transport = context().transport();
      transport.initialize();
      transport.servers.tcp(
        io.InternetAddress("0.0.0.0"),
        12345,
        (connection) => connection.stream().listen(
          (event) {
            Validators.request(event.takeBytes());
            connection.writeSingle(Generators.response());
          },
        ),
      );
      final clients = await transport.clients.tcp(io.InternetAddress("127.0.0.1"), 12345, configuration: TransportDefaults.tcpClient.copyWith(pool: clientsPool));
      final latch = Latch(clientsPool);
      clients.forEach((client) {
        client.writeSingle(Generators.request());
        client.stream().listen((value) {
          Validators.response(value.takeBytes());
          latch.countDown();
        });
      });
      await latch.done();
      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}

void testTcpMany({required int index, required int clientsPool, required int count}) {
  test(
    "(many) [clients = $clientsPool, count = $count]",
    () => runTest(() async {
      final transport = context().transport();
      transport.initialize();
      transport.servers.tcp(
        io.InternetAddress("0.0.0.0"),
        12345,
        (connection) {
          final serverRequests = BytesBuilder();
          connection.stream().listen(
            (event) {
              serverRequests.add(event.takeBytes());
              if (serverRequests.length == Generators.requestsSumOrdered(count).length) {
                Validators.requestsSumOrdered(serverRequests.takeBytes(), count);
                connection.writeMany(Generators.responsesOrdered(count));
              }
            },
          );
        },
      );
      final clients = await transport.clients.tcp(
        io.InternetAddress("127.0.0.1"),
        12345,
        configuration: TransportDefaults.tcpClient.copyWith(pool: clientsPool),
      );
      final latch = Latch(clientsPool);
      clients.forEach((client) {
        client.writeMany(Generators.requestsOrdered(count));
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
      });
      await latch.done();
      await transport.shutdown(gracefulTimeout: Duration(milliseconds: 100));
    }),
  );
}
