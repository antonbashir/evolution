// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

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

final class transport_client extends Struct {
  @Int32()
  external int fd;
  external Pointer<sockaddr_in> inet_destination_address;
  external Pointer<sockaddr_in> inet_source_address;
  external Pointer<sockaddr_un> unix_destination_address;
  @Uint32()
  external int client_address_length;
  @Uint8()
  external int family;
}

@Native<Int32 Function(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Utf8> ip, Int32 port)>(isLeaf: true)
external int transport_client_initialize_tcp(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Utf8> ip, int port);

@Native<Int32 Function(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Utf8> destination_ip, Int32 destination_port, Pointer<Utf8> source_ip, Int32 source_port)>(isLeaf: true)
external int transport_client_initialize_udp(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Utf8> destination_ip, int destination_port, Pointer<Utf8> source_ip, int source_port);

@Native<Int32 Function(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Utf8> path)>(isLeaf: true)
external int transport_client_initialize_unix_stream(Pointer<transport_client> client, Pointer<transport_client_configuration> configuration, Pointer<Utf8> path);

@Native<Pointer<sockaddr> Function(Pointer<transport_client> client)>(isLeaf: true)
external Pointer<sockaddr> transport_client_get_destination_address(Pointer<transport_client> client);

@Native<Void Function(Pointer<transport_client> client)>(isLeaf: true)
external void transport_client_destroy(Pointer<transport_client> client);
