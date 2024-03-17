// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

final class transport extends Struct {
  external Pointer<iovec> buffers;
  external Pointer<executor_instance> transport_executor;
  external transport_configuration configuration;
}

@Native<Pointer<transport> Function(Pointer<transport_configuration> configuration)>(isLeaf: true)
external Pointer<transport> transport_initialize(Pointer<transport_configuration> configuration);

@Native<Int32 Function(Pointer<transport> transport, Pointer<executor_instance> executor)>(isLeaf: true)
external int transport_setup(Pointer<transport> transport, Pointer<executor_instance> executor);

@Native<Int8 Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Uint32 offset, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external int transport_write(Pointer<transport> transport, int fd, int buffer_id, int offset, int timeout, int event, int sqe_flags);

@Native<Int8 Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Uint32 offset, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external int transport_read(Pointer<transport> transport, int fd, int buffer_id, int offset, int timeout, int event, int sqe_flags);

@Native<Int8 Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Pointer<sockaddr> address, Uint8 socket_family, Int32 message_flags, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external int transport_send_message(Pointer<transport> transport, int fd, int buffer_id, Pointer<sockaddr> address, int socket_family, int message_flags, int timeout, int event, int sqe_flags);

@Native<Int8 Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Uint8 socket_family, Int32 message_flags, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external int transport_receive_message(Pointer<transport> transport, int fd, int buffer_id, int socket_family, int message_flags, int timeout, int event, int sqe_flags);

@Native<Int8 Function(Pointer<transport> transport, Pointer<transport_client> client, Int64 timeout)>(isLeaf: true)
external int transport_connect(Pointer<transport> transport, Pointer<transport_client> client, int timeout);

@Native<Int8 Function(Pointer<transport> transport, Pointer<transport_server> server)>(isLeaf: true)
external int transport_accept(Pointer<transport> transport, Pointer<transport_server> server);

@Native<Int8 Function(Pointer<transport> transport, Int32 fd)>(isLeaf: true)
external int transport_cancel_by_fd(Pointer<transport> transport, int fd);

@Native<Void Function(Pointer<transport> transport)>(isLeaf: true)
external void transport_check_event_timeouts(Pointer<transport> transport);

@Native<Void Function(Pointer<transport> transport, Uint64 data)>(isLeaf: true)
external void transport_remove_event(Pointer<transport> transport, int data);

@Native<Pointer<sockaddr> Function(Pointer<transport> transport, Uint8 socket_family, Int32 buffer_id)>(isLeaf: true)
external Pointer<sockaddr> transport_get_datagram_address(Pointer<transport> transport, int socket_family, int buffer_id);

@Native<Void Function(Pointer<transport> transport)>(isLeaf: true)
external void transport_destroy(Pointer<transport> transport);
