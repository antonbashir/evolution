import 'dart:ffi';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:memory/memory.dart';

import 'bindings.dart';
import 'constants.dart';

class TransportChannel {
  final int fd;
  final Pointer<transport> _workerPointer;
  final MemoryStaticBuffers _buffers;

  const TransportChannel(this._workerPointer, this.fd, this._buffers);

  @inline
  void read(
    int bufferId,
    int event, {
    int sqeFlags = 0,
    int offset = 0,
    int? timeout,
  }) {
    transport_read(
      _workerPointer,
      fd,
      bufferId,
      offset,
      timeout ?? transportTimeoutInfinity,
      event,
      sqeFlags,
    );
  }

  @inline
  void write(
    Uint8List bytes,
    int bufferId,
    int event, {
    int sqeFlags = 0,
    int offset = 0,
    int? timeout,
  }) {
    _buffers.write(bufferId, bytes);
    transport_write(
      _workerPointer,
      fd,
      bufferId,
      offset,
      timeout ?? transportTimeoutInfinity,
      event,
      sqeFlags,
    );
  }

  @inline
  void receiveMessage(
    int bufferId,
    int socketFamily,
    int messageFlags,
    int event, {
    int? timeout,
    int sqeFlags = 0,
  }) {
    transport_receive_message(
      _workerPointer,
      fd,
      bufferId,
      socketFamily,
      messageFlags,
      timeout ?? transportTimeoutInfinity,
      event,
      sqeFlags,
    );
  }

  @inline
  void sendMessage(
    Uint8List bytes,
    int bufferId,
    int socketFamily,
    Pointer<sockaddr> destination,
    int messageFlags,
    int event, {
    int? timeout,
    int sqeFlags = 0,
  }) {
    _buffers.write(bufferId, bytes);
    transport_send_message(
      _workerPointer,
      fd,
      bufferId,
      destination,
      socketFamily,
      messageFlags,
      timeout ?? transportTimeoutInfinity,
      event,
      sqeFlags,
    );
  }

  @inline
  void close() => systemShutdownDescriptor(fd);
}
