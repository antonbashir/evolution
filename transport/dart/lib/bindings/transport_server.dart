// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

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
  @Int16()
  external int family;
  external Pointer<sockaddr_in> inet_server_address;
  external Pointer<sockaddr_un> unix_server_address;
  @Int32()
  external int server_address_length;
}

@Native<Int32 Function(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Utf8> ip, Int32 port)>(isLeaf: true)
external int transport_server_initialize_tcp(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Utf8> ip, int port);

@Native<Int32 Function(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Utf8> ip, Int32 port)>(isLeaf: true)
external int transport_server_initialize_udp(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Utf8> ip, int port);

@Native<Int32 Function(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Utf8> path)>(isLeaf: true)
external int transport_server_initialize_unix_stream(Pointer<transport_server> server, Pointer<transport_server_configuration> configuration, Pointer<Utf8> path);

@Native<Void Function(Pointer<transport_server> server)>(isLeaf: true)
external void transport_server_destroy(Pointer<transport_server> server);
