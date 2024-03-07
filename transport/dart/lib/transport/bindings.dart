import 'dart:ffi';
import 'package:core/core.dart';
import 'package:executor/executor.dart';
import 'package:memory/memory.dart' as memory;

@Native<Int32 Function(Pointer<transport_client>, Pointer<transport_client_configuration>, Pointer<Char>, Int32)>(
  symbol: 'transport_client_initialize_tcp',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_client_initialize_tcp(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Char> ip, int port);

@Native<Int32 Function(Pointer<transport_client>, Pointer<transport_client_configuration>, Pointer<Char>, Int32, Pointer<Char>, Int32)>(
  symbol: 'transport_client_initialize_udp',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_client_initialize_udp(
  Pointer<transport_client> client,
  Pointer<transport_client_configuration> configuration,
  Pointer<Char> destination_ip,
  int destination_port,
  Pointer<Char> source_ip,
  int source_port,
);

@Native<Int32 Function(Pointer<transport_client>, Pointer<transport_client_configuration>, Pointer<Char>)>(
  symbol: 'transport_client_initialize_unix_stream',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_client_initialize_unix_stream(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Char> path);

@Native<Pointer<sockaddr> Function(Pointer<transport_client>)>(
  symbol: 'transport_client_get_destination_address',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external Pointer<sockaddr> transport_client_get_destination_address(Pointer<transport_client> client);

@Native<Void Function(Pointer<transport_client>)>(
  symbol: 'transport_client_destroy',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_client_destroy(Pointer<transport_client> client);

@Native<Int32 Function(Pointer<transport_server>, Pointer<transport_server_configuration>, Pointer<Char>, Int32)>(
  symbol: 'transport_server_initialize_tcp',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_server_initialize_tcp(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Char> ip, int port);

@Native<Int32 Function(Pointer<transport_server>, Pointer<transport_server_configuration>, Pointer<Char>, Int32)>(
  symbol: 'transport_server_initialize_udp',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_server_initialize_udp(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Char> ip, int port);

@Native<Int32 Function(Pointer<transport_server>, Pointer<transport_server_configuration>, Pointer<Char>)>(
  symbol: 'transport_server_initialize_unix_stream',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_server_initialize_unix_stream(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Char> path);

@Native<Void Function(Pointer<transport_server>)>(
  symbol: 'transport_server_destroy',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_server_destroy(Pointer<transport_server> server);

@Native<Int32 Function(Pointer<transport>, Pointer<transport_configuration>, Uint8)>(
  symbol: 'transport_initialize',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_initialize(Pointer<transport> transport, Pointer<transport_configuration> configuration, int id);

@Native<Int32 Function(Pointer<transport>, Pointer<executor_dart>)>(
  symbol: 'transport_setup',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_setup(Pointer<transport> transport, Pointer<executor_dart> executor);

@Native<Void Function(Pointer<transport>, Uint32, Uint16, Uint32, Int64, Uint16, Uint8)>(
  symbol: 'transport_write',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_write(Pointer<transport> transport, int fd, int buffer_id, int offset, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport>, Uint32, Uint16, Uint32, Int64, Uint16, Uint8)>(
  symbol: 'transport_read',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_read(Pointer<transport> transport, int fd, int buffer_id, int offset, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport>, Uint32, Uint16, Pointer<sockaddr>, Int32, Int32, Int64, Uint16, Uint8)>(
  symbol: 'transport_send_message',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_send_message(Pointer<transport> transport, int fd, int buffer_id, Pointer<sockaddr> address, int socket_family, int message_flags, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport>, Uint32, Uint16, Int32, Int32, Int64, Uint16, Uint8)>(
  symbol: 'transport_receive_message',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_receive_message(Pointer<transport> transport, int fd, int buffer_id, int socket_family, int message_flags, int timeout, int event, int sqe_flags);

@Native<Void Function(Pointer<transport>, Pointer<transport_client>, Int64)>(
  symbol: 'transport_connect',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_connect(Pointer<transport> transport, Pointer<transport_client> client, int timeout);

@Native<Void Function(Pointer<transport>, Pointer<transport_server>)>(
  symbol: 'transport_accept',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_accept(Pointer<transport> transport, Pointer<transport_server> server);

@Native<Void Function(Pointer<transport>, Int32)>(
  symbol: 'transport_cancel_by_fd',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_cancel_by_fd(Pointer<transport> transport, int fd);

@Native<Void Function(Pointer<transport>)>(
  symbol: 'transport_check_event_timeouts',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_check_event_timeouts(Pointer<transport> transport);

@Native<Void Function(Pointer<transport>, Uint64)>(
  symbol: 'transport_remove_event',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_remove_event(Pointer<transport> transport, int data);

@Native<Pointer<sockaddr> Function(Pointer<transport>, Int32, Int32)>(
  symbol: 'transport_get_datagram_address',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external Pointer<sockaddr> transport_get_datagram_address(Pointer<transport> transport, int socket_family, int buffer_id);

@Native<Void Function(Pointer<transport>)>(
  symbol: 'transport_destroy',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_destroy(Pointer<transport> transport);

@Native<Int32 Function(Pointer<Char>, Int32, Bool, Bool)>(
  symbol: 'transport_file_open',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_file_open(Pointer<Char> path, int mode, bool truncate, bool create);

@Native<Int64 Function(Uint64, Uint32, Uint32, Uint32, Uint32, Uint16, Uint32, Uint32, Uint32, Uint32, Uint16)>(
  symbol: 'transport_socket_create_tcp',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_create_tcp(
  int flags,
  int socket_receive_buffer_size,
  int socket_send_buffer_size,
  int socket_receive_low_at,
  int socket_send_low_at,
  int ip_ttl,
  int tcp_keep_alive_idle,
  int tcp_keep_alive_max_count,
  int tcp_keep_alive_individual_count,
  int tcp_max_segment_size,
  int tcp_syn_count,
);

@Native<Int64 Function(Uint64, Uint32, Uint32, Uint32, Uint32, Uint16, Pointer<ip_mreqn>, Uint32)>(
  symbol: 'transport_socket_create_udp',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_create_udp(
  int flags,
  int socket_receive_buffer_size,
  int socket_send_buffer_size,
  int socket_receive_low_at,
  int socket_send_low_at,
  int ip_ttl,
  Pointer<ip_mreqn> ip_multicast_interface,
  int ip_multicast_ttl,
);

@Native<Int64 Function(Uint64, Uint32, Uint32, Uint32, Uint32)>(
  symbol: 'transport_socket_create_unix_stream',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_create_unix_stream(
  int flags,
  int socket_receive_buffer_size,
  int socket_send_buffer_size,
  int socket_receive_low_at,
  int socket_send_low_at,
);

@Native<Void Function(Pointer<ip_mreqn>, Pointer<Char>, Pointer<Char>, Int32)>(
  symbol: 'transport_socket_initialize_multicast_request',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external void transport_socket_initialize_multicast_request(
  Pointer<ip_mreqn> request,
  Pointer<Char> group_address,
  Pointer<Char> local_address,
  int interface_index,
);

@Native<Int32 Function(Int32, Pointer<Char>, Pointer<Char>, Int32)>(
  symbol: 'transport_socket_multicast_add_membership',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_multicast_add_membership(
  int fd,
  Pointer<Char> group_address,
  Pointer<Char> local_address,
  int interface_index,
);

@Native<Int32 Function(Int32, Pointer<Char>, Pointer<Char>, Int32)>(
  symbol: 'transport_socket_multicast_drop_membership',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_multicast_drop_membership(
  int fd,
  Pointer<Char> group_address,
  Pointer<Char> local_address,
  int interface_index,
);

@Native<Int32 Function(Int32, Pointer<Char>, Pointer<Char>, Pointer<Char>)>(
  symbol: 'transport_socket_multicast_add_source_membership',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_multicast_add_source_membership(
  int fd,
  Pointer<Char> group_address,
  Pointer<Char> local_address,
  Pointer<Char> source_address,
);

@Native<Int32 Function(Int32, Pointer<Char>, Pointer<Char>, Pointer<Char>)>(
  symbol: 'transport_socket_multicast_drop_source_membership',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_multicast_drop_source_membership(
  int fd,
  Pointer<Char> group_address,
  Pointer<Char> local_address,
  Pointer<Char> source_address,
);

@Native<Int32 Function(Pointer<Char>)>(
  symbol: 'transport_socket_get_interface_index',
  assetId: 'transport-bindings',
  isLeaf: true,
)
external int transport_socket_get_interface_index(Pointer<Char> interface1);

final class executor_native_configuration extends Struct {
  @Uint64()
  external int completion_wait_timeout_millis;

  @Size()
  external int quota_size;

  @Size()
  external int preallocation_size;

  @Size()
  external int slab_size;

  @Size()
  external int static_buffers_capacity;

  @Size()
  external int static_buffer_size;

  @Size()
  external int ring_size;

  @Int32()
  external int ring_flags;

  @Uint32()
  external int completion_wait_count;
}

final class executor_scheduler_configuration extends Struct {
  @Size()
  external int ring_size;

  @Size()
  external int ring_flags;

  @Uint64()
  external int initialization_timeout_seconds;

  @Uint64()
  external int shutdown_timeout_seconds;

  @Bool()
  external bool trace;
}

abstract class transport_socket_family {
  static const int INET = 0;
  static const int UNIX = 1;
}

final class sockaddr_in extends Opaque {}

final class sockaddr_un extends Opaque {}

final class transport_client_configuration extends Struct {
  @Uint64()
  external int socket_configuration_flags;

  @Uint32()
  external int socket_receive_buffer_size;

  @Uint32()
  external int socket_send_buffer_size;

  @Uint32()
  external int socket_receive_low_at;

  @Uint32()
  external int socket_send_low_at;

  @Uint16()
  external int ip_ttl;

  @Uint32()
  external int tcp_keep_alive_idle;

  @Uint32()
  external int tcp_keep_alive_max_count;

  @Uint32()
  external int tcp_keep_alive_individual_count;

  @Uint32()
  external int tcp_max_segment_size;

  @Uint16()
  external int tcp_syn_count;

  external Pointer<ip_mreqn> ip_multicast_interface;

  @Uint32()
  external int ip_multicast_ttl;
}

final class ip_mreqn extends Opaque {}

final class transport_client extends Struct {
  @Int32()
  external int fd;

  external Pointer<sockaddr_in> inet_destination_address;

  external Pointer<sockaddr_in> inet_source_address;

  external Pointer<sockaddr_un> unix_destination_address;

  @UnsignedInt()
  external int client_address_length;

  @Int32()
  external int family;
}

final class sockaddr extends Opaque {}

final class transport_server_configuration extends Struct {
  @Int32()
  external int socket_max_connections;

  @Uint64()
  external int socket_configuration_flags;

  @Uint32()
  external int socket_receive_buffer_size;

  @Uint32()
  external int socket_send_buffer_size;

  @Uint32()
  external int socket_receive_low_at;

  @Uint32()
  external int socket_send_low_at;

  @Uint16()
  external int ip_ttl;

  @Uint32()
  external int tcp_keep_alive_idle;

  @Uint32()
  external int tcp_keep_alive_max_count;

  @Uint32()
  external int tcp_keep_alive_individual_count;

  @Uint32()
  external int tcp_max_segment_size;

  @Uint16()
  external int tcp_syn_count;

  external Pointer<ip_mreqn> ip_multicast_interface;

  @Uint32()
  external int ip_multicast_ttl;
}

final class transport_server extends Struct {
  @Int32()
  external int fd;

  @Int32()
  external int family;

  external Pointer<sockaddr_in> inet_server_address;

  external Pointer<sockaddr_un> unix_server_address;

  @UnsignedInt()
  external int server_address_length;
}

final class mh_events_t extends Opaque {}

final class transport_configuration extends Struct {
  external memory.memory_configuration memory_configuration;

  external executor_dart_configuration executor_configuration;

  @Uint64()
  external int timeout_checker_period_millis;

  @Bool()
  external bool trace;
}

final class transport extends Struct {
  @Uint8()
  external int id;

  external Pointer<iovec> buffers;

  external Pointer<executor_dart> transport_executor;

  external transport_configuration configuration;

  external Pointer<msghdr> inet_used_messages;

  external Pointer<msghdr> unix_used_messages;

  external Pointer<mh_events_t> events;
}

final class msghdr extends Opaque {}
