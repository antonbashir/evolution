import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:mediator/mediator/constants.dart';
import 'package:transport/transport.dart';

Future<void> main(List<String> args) async {
  await _benchMyTcp();
  await _benchDartTcp();
}

Future<void> _benchMyTcp() async {
  final transport = TransportModule()..initialize();
  final encoder = Utf8Encoder();
  final fromServer = encoder.convert("from server\n");

  for (var i = 0; i < 8; i++) {
    Isolate.spawn((SendPort message) async {
      final worker = Transport(message);
      await worker.initialize();
      worker.servers.tcp(
        InternetAddress("0.0.0.0"),
        12345,
        (connection) => connection.stream().listen((payload) {
          payload.release();
          connection.writeSingle(fromServer);
        }),
      );
    }, transport.transport(configuration: TransportDefaults.transport.copyWith()));
  }
  await Future.delayed(Duration(seconds: 1));
  for (var i = 0; i < 8; i++) {
    Isolate.spawn((SendPort message) async {
      final worker = Transport(message);
      await worker.initialize();
      final connector = await worker.clients.tcp(InternetAddress("127.0.0.1"), 12345, configuration: TransportDefaults.tcpClient.copyWith(pool: 256));
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
    }, transport.transport(configuration: TransportDefaults.transport));
  }

  await Future.delayed(Duration(seconds: 15));
  await transport.shutdown();
}

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
