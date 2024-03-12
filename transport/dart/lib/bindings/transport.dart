// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

final class simple_map_events_t extends Opaque {}

final class executor extends Opaque {}

final class ip_mreqn extends Opaque {}

final class sockaddr extends Opaque {}

final class sockaddr_in extends Opaque {}

final class sockaddr_un extends Opaque {}

final class msghdr extends Opaque {}

final class transport_configuration extends Struct {
  external memory_configuration memory_instance_configuration;
  external executor_configuration executor_configuration;
  @Uint64()
  external int timeout_checker_period_milliseconds;
  @Bool()
  external bool trace;
}

final class transport extends Struct {
  @Uint8()
  external int id;
  external Pointer<iovec> buffers;
  external Pointer<executor> transport_executor;
  external transport_configuration configuration;
  external Pointer<msghdr> inet_used_messages;
  external Pointer<msghdr> unix_used_messages;
  external Pointer<simple_map_events_t> events;
}

@Native<Int32 Function(Pointer<transport> transport, Pointer<transport_configuration> configuration, Uint8 id)>(isLeaf: true)
external int transport_initialize(Pointer<transport> transport, Pointer<transport_configuration> configuration, int id);

@Native<Int32 Function(Pointer<transport> transport, Pointer<executor> executor)>(isLeaf: true)
external int transport_setup(Pointer<transport> transport, Pointer<executor> executor);

@Native<Void Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Uint32 offset, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external void transport_write(Pointer<transport> transport, int fd, int buffer_id, int offset, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Uint32 offset, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external void transport_read(Pointer<transport> transport, int fd, int buffer_id, int offset, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Pointer<sockaddr> address, Uint8 socket_family, Int32 message_flags, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external void transport_send_message(Pointer<transport> transport, int fd, int buffer_id, Pointer<sockaddr> address, int socket_family, int message_flags, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport> transport, Uint32 fd, Uint16 buffer_id, Uint8 socket_family, Int32 message_flags, Int64 timeout, Uint16 event, Uint8 sqe_flags)>(isLeaf: true)
external void transport_receive_message(Pointer<transport> transport, int fd, int buffer_id, int socket_family, int message_flags, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport> transport, Pointer<transport_client> client, Int64 timeout)>(isLeaf: true)
external void transport_connect(Pointer<transport> transport, Pointer<transport_client> client, int timeout);

@Native<Void Function(Pointer<transport> transport, Pointer<transport_server> server)>(isLeaf: true)
external void transport_accept(Pointer<transport> transport, Pointer<transport_server> server);

@Native<Void Function(Pointer<transport> transport, Int32 fd)>(isLeaf: true)
external void transport_cancel_by_fd(Pointer<transport> transport, int fd);

@Native<Void Function(Pointer<transport> transport)>(isLeaf: true)
external void transport_check_event_timeouts(Pointer<transport> transport);

@Native<Void Function(Pointer<transport> transport, Uint64 data)>(isLeaf: true)
external void transport_remove_event(Pointer<transport> transport, int data);

@Native<Pointer<sockaddr> Function(Pointer<transport> transport, Uint8 socket_family, Int32 buffer_id)>(isLeaf: true)
external Pointer<sockaddr> transport_get_datagram_address(Pointer<transport> transport, int socket_family, int buffer_id);

@Native<Void Function(Pointer<transport> transport)>(isLeaf: true)
external void transport_destroy(Pointer<transport> transport);
