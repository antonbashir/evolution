import 'dart:ffi';

import 'package:core/core.dart';

final transportLibraryName = context().environment().debug ? "libtransport_debug_${Abi.current()}.so" : "libtransport_release_${Abi.current()}.so";
const transportModuleName = "transport";

const transportBufferUsed = -1;

const transportEventRead = 1 << 0;
const transportEventWrite = 1 << 1;
const transportEventReceiveMessage = 1 << 2;
const transportEventSendMessage = 1 << 3;
const transportEventAccept = 1 << 4;
const transportEventConnect = 1 << 5;
const transportEventClient = 1 << 6;
const transportEventFile = 1 << 7;
const transportEventServer = 1 << 8;

const transportEventAll = transportEventRead |
    transportEventWrite |
    transportEventAccept |
    transportEventConnect |
    transportEventReceiveMessage |
    transportEventSendMessage |
    transportEventClient |
    transportEventFile |
    transportEventServer;

const transportSocketOptionSocketNonblock = 1 << 1;
const transportSocketOptionSocketCloexec = 1 << 2;
const transportSocketOptionSocketReuseaddr = 1 << 3;
const transportSocketOptionSocketReuseport = 1 << 4;
const transportSocketOptionSocketRcvbuf = 1 << 5;
const transportSocketOptionSocketSndbuf = 1 << 6;
const transportSocketOptionSocketBroadcast = 1 << 7;
const transportSocketOptionSocketKeepalive = 1 << 8;
const transportSocketOptionSocketRcvlowat = 1 << 9;
const transportSocketOptionSocketSndlowat = 1 << 10;
const transportSocketOptionIpTtl = 1 << 11;
const transportSocketOptionIpAddMembership = 1 << 12;
const transportSocketOptionIpAddSourceMembership = 1 << 13;
const transportSocketOptionIpDropMembership = 1 << 14;
const transportSocketOptionIpDropSourceMembership = 1 << 15;
const transportSocketOptionIpFreebind = 1 << 16;
const transportSocketOptionIpMulticastAll = 1 << 17;
const transportSocketOptionIpMulticastIf = 1 << 18;
const transportSocketOptionIpMulticastLoop = 1 << 19;
const transportSocketOptionIpMulticastTtl = 1 << 20;
const transportSocketOptionTcpQuickack = 1 << 21;
const transportSocketOptionTcpDeferAccept = 1 << 22;
const transportSocketOptionTcpFastopen = 1 << 23;
const transportSocketOptionTcpKeepidle = 1 << 24;
const transportSocketOptionTcpKeepcnt = 1 << 25;
const transportSocketOptionTcpKeepintvl = 1 << 26;
const transportSocketOptionTcpMaxseg = 1 << 27;
const transportSocketOptionTcpNoDelay = 1 << 28;
const transportSocketOptionTcpSyncnt = 1 << 29;

const transportTimeoutInfinity = -1;

enum TransportDatagramMessageFlag {
  oob(0x01),
  peek(0x02),
  dontroute(0x04),
  tryhard(0x04),
  ctrunc(0x08),
  proxy(0x10),
  trunc(0x20),
  dontwait(0x40),
  eor(0x80),
  waitall(0x100),
  fin(0x200),
  syn(0x400),
  confirm(0x800),
  rst(0x1000),
  errqueue(0x2000),
  nosignal(0x4000),
  more(0x8000),
  waitforone(0x10000),
  batch(0x40000),
  zerocopy(0x4000000),
  fastopen(0x20000000),
  cmsgCloexec(0x40000000);

  final int flag;

  const TransportDatagramMessageFlag(this.flag);
}

enum TransportEvent {
  accept,
  connect,
  serverRead,
  serverWrite,
  clientRead,
  clientWrite,
  serverReceive,
  serverSend,
  clientReceive,
  clientSend,
  fileRead,
  fileWrite,
  unknown;

  static TransportEvent serverEvent(int event) {
    if (event == transportEventRead) return TransportEvent.serverRead;
    if (event == transportEventWrite) return TransportEvent.serverWrite;
    if (event == transportEventSendMessage) return TransportEvent.serverSend;
    if (event == transportEventReceiveMessage) return TransportEvent.serverReceive;
    if (event == transportEventAccept) return TransportEvent.accept;
    return TransportEvent.unknown;
  }

  static TransportEvent fileEvent(int event) {
    if (event == transportEventRead) return TransportEvent.fileRead;
    if (event == transportEventWrite) return TransportEvent.fileWrite;
    return TransportEvent.unknown;
  }

  static TransportEvent clientEvent(int event) {
    if (event == transportEventRead) return TransportEvent.clientRead;
    if (event == transportEventWrite) return TransportEvent.clientWrite;
    if (event == transportEventSendMessage) return TransportEvent.clientSend;
    if (event == transportEventReceiveMessage) return TransportEvent.clientReceive;
    if (event == transportEventConnect) return TransportEvent.connect;
    return TransportEvent.unknown;
  }

  @override
  String toString() => name;
}

enum TransportFileMode {
  readOnly(1 << 0),
  writeOnly(1 << 1),
  readWrite(1 << 2),
  writeOnlyAppend(1 << 3),
  readWriteAppend(1 << 4);

  final int mode;

  const TransportFileMode(this.mode);
}

class TransportMessages {
  TransportMessages._();

  static final workerMemoryError = "[worker] out of memory";
  static workerError(int result) => "[worker] code = $result, message = ${SystemErrors.of(result)}";
  static workerTrace(TransportEvent event, int result, int data, int fd) => "event = $event, result = $result,  bid = ${((data >> 16) & 0xffff)}, fd = $fd";

  static final serverMemoryError = "[server] out of memory";
  static final serverClosedError = "[server] closed";
  static serverError(int result) => "[server] code = $result, message = ${SystemErrors.of(result)}";
  static serverSocketError(int result) => "[server] unable to set socket option: ${-result}";

  static final clientMemoryError = "[client] out of memory";
  static final clientClosedError = "[client] closed";
  static clientError(int result) => "[client] code = $result, message = ${SystemErrors.of(result)}";
  static clientSocketError(int result) => "[client] unable to set socket option: ${-result}";

  static final fileMemory = "[file] out of memory";
  static final fileClosedError = "[file] closed";
  static fileOpenError(String path) => "[file] open file failed: $path";
  static fileError(int result) => "[file] code = $result, message = ${SystemErrors.of(result)}";

  static internalError(TransportEvent event, int code) => "[$event] code = $code, message = ${SystemErrors.of(code)}";
  static canceledError(TransportEvent event) => "[$event] canceled";
  static zeroDataError(TransportEvent event) => "[$event] completed with zero result (no data)";
}
