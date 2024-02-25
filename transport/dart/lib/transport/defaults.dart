import 'package:memory/memory/defaults.dart';

import 'client/configuration.dart';
import 'configuration.dart';
import 'server/configuration.dart';

class TransportDefaults {
  TransportDefaults._();

  static const worker = TransportConfiguration(
    memoryConfiguration: MemoryDefaults.memory,
    trace: false,
    buffersCapacity: 4096,
    bufferSize: 4096,
    ringSize: 16384,
    ringFlags: 0,
    timeoutCheckerPeriod: Duration(milliseconds: 500),
    baseDelay: Duration(microseconds: 10),
    maxDelay: Duration(seconds: 5),
    delayRandomizationFactor: 0.25,
    cqePeekCount: 1024,
    cqeWaitCount: 1,
    cqeWaitTimeout: Duration(milliseconds: 1),
  );

  static const tcpClient = TransportTcpClientConfiguration(
    socketReceiveBufferSize: 4 * 1024 * 1024,
    socketSendBufferSize: 4 * 1024 * 1024,
    pool: 1,
    connectTimeout: Duration(seconds: 60),
    readTimeout: Duration(seconds: 60),
    writeTimeout: Duration(seconds: 60),
    socketNonblock: true,
    socketCloexec: true,
    tcpFastopen: true,
    tcpNoDelay: true,
    tcpQuickack: true,
    tcpDeferAccept: true,
  );

  static const udpClient = TransportUdpClientConfiguration(
    socketReceiveBufferSize: 4 * 1024 * 1024,
    socketSendBufferSize: 4 * 1024 * 1024,
    readTimeout: Duration(seconds: 60),
    writeTimeout: Duration(seconds: 60),
    socketNonblock: true,
    socketCloexec: true,
  );

  static const unixStreamClient = TransportUnixStreamClientConfiguration(
    socketReceiveBufferSize: 4 * 1024 * 1024,
    socketSendBufferSize: 4 * 1024 * 1024,
    pool: 1,
    connectTimeout: Duration(seconds: 60),
    readTimeout: Duration(seconds: 60),
    writeTimeout: Duration(seconds: 60),
    socketNonblock: true,
    socketCloexec: true,
  );

  static const tcpServer = TransportTcpServerConfiguration(
    socketMaxConnections: 4096,
    socketReceiveBufferSize: 4 * 1024 * 1024,
    socketSendBufferSize: 4 * 1024 * 1024,
    socketReusePort: true,
    socketNonblock: true,
    socketCloexec: true,
    tcpFastopen: true,
    tcpNoDelay: true,
    tcpQuickack: true,
    tcpDeferAccept: true,
  );

  static const udpServer = TransportUdpServerConfiguration(
    socketReceiveBufferSize: 4 * 1024 * 1024,
    socketSendBufferSize: 4 * 1024 * 1024,
    socketReusePort: true,
    socketNonblock: true,
    socketCloexec: true,
  );

  static const unixStreamServer = TransportUnixStreamServerConfiguration(
    socketMaxConnections: 4096,
    socketReceiveBufferSize: 4 * 1024 * 1024,
    socketSendBufferSize: 4 * 1024 * 1024,
    socketNonblock: true,
    socketCloexec: true,
  );
}
