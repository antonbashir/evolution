import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:transport/transport.dart';
import 'package:transport/transport/bindings.dart';

Future<void> main(List<String> args) async {
  await _benchMyTcp();
  await _benchDartTcp();
}

Future<void> _benchMyTcp() async => await launch(
      [
        CoreModule.new,
        MemoryModule.new,
        ExecutorModule.new,
        TransportModule.new,
      ],
      () async {
        final encoder = Utf8Encoder();
        final fromServer = encoder.convert("from server\n");
        for (var i = 0; i < 8; i++) {
          Isolate.run(() => fork(
                () async {
                  final transport = context().transport()..initialize();
                  transport.servers.tcp(
                    InternetAddress("0.0.0.0"),
                    12345,
                    (connection) => connection.stream().listen((payload) {
                      payload.release();
                      connection.writeSingle(fromServer);
                    }),
                  );
                  block();
                },
              ));
        }
        await Future.delayed(Duration(seconds: 1));
        for (var i = 0; i < 8; i++) {
          Isolate.run(() => fork(
                () async {
                  final transport = context().transport()..initialize();
                  final connector = await transport.clients.tcp(InternetAddress("127.0.0.1"), 12345, configuration: TransportDefaults.tcpClient.copyWith(pool: 256));
                  var count = 0;
                  final time = Stopwatch();
                  time.start();
                  for (var client in connector.clients) {
                    client.stream().listen((element) {
                      count++;
                      element.release();
                      client.writeSingle(fromServer);
                    });
                    client.writeSingle(fromServer);
                  }
                  await Future.delayed(Duration(seconds: 10));
                  print("My RPS: ${count / 10}");
                  block();
                },
              ));
        }
        await Future.delayed(Duration(seconds: 15));
      },
    );

Future<void> _benchDartTcp() async {
  final encoder = Utf8Encoder();
  final fromServer = encoder.convert("from server\n");
  for (var i = 0; i < 2; i++) {
    Isolate.spawn((_) async {
      ServerSocket.bind(InternetAddress("127.0.0.1"), 2345, shared: true).then((server) {
        server.listen((client) {
          client.listen((event) {
            client.write(fromServer);
          });
        });
      });
    }, null);
  }
  await Future.delayed(Duration(seconds: 1));
  for (var i = 0; i < 2; i++) {
    Isolate.spawn((_) async {
      final sockets = <Socket>[];
      for (var i = 0; i < 256; i++) {
        sockets.add(await Socket.connect("127.0.0.1", 2345));
      }
      var count = 0;
      final time = Stopwatch();
      time.start();
      for (var client in sockets) {
        client.listen((element) {
          count++;
          client.write(fromServer);
        });
        client.write(fromServer);
      }
      await Future.delayed(Duration(seconds: 10));
      print("Dart RPS: ${count / 10}");
    }, null);
  }

  await Future.delayed(Duration(seconds: 15));
}
