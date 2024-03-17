// Generated
// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

@Native<Int64 Function(Uint64 flags, Uint32 socket_receive_buffer_size, Uint32 socket_send_buffer_size, Uint32 socket_receive_low_at, Uint32 socket_send_low_at, Uint16 ip_ttl, Uint32 tcp_keep_alive_idle, Uint32 tcp_keep_alive_max_count, Uint32 tcp_keep_alive_individual_count, Uint32 tcp_max_segment_size, Uint16 tcp_syn_count)>(isLeaf: true)
external int transport_socket_create_tcp(int flags, int socket_receive_buffer_size, int socket_send_buffer_size, int socket_receive_low_at, int socket_send_low_at, int ip_ttl, int tcp_keep_alive_idle, int tcp_keep_alive_max_count, int tcp_keep_alive_individual_count, int tcp_max_segment_size, int tcp_syn_count);

@Native<Int64 Function(Uint64 flags, Uint32 socket_receive_buffer_size, Uint32 socket_send_buffer_size, Uint32 socket_receive_low_at, Uint32 socket_send_low_at, Uint16 ip_ttl, Pointer<ip_mreqn> ip_multicast_interface, Uint32 ip_multicast_ttl)>(isLeaf: true)
external int transport_socket_create_udp(int flags, int socket_receive_buffer_size, int socket_send_buffer_size, int socket_receive_low_at, int socket_send_low_at, int ip_ttl, Pointer<ip_mreqn> ip_multicast_interface, int ip_multicast_ttl);

@Native<Int64 Function(Uint64 flags, Uint32 socket_receive_buffer_size, Uint32 socket_send_buffer_size, Uint32 socket_receive_low_at, Uint32 socket_send_low_at)>(isLeaf: true)
external int transport_socket_create_unix_stream(int flags, int socket_receive_buffer_size, int socket_send_buffer_size, int socket_receive_low_at, int socket_send_low_at);

@Native<Void Function(Pointer<ip_mreqn> request, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Int32 interface_index)>(isLeaf: true)
external void transport_socket_initialize_multicast_request(Pointer<ip_mreqn> request, Pointer<Utf8> group_address, Pointer<Utf8> local_address, int interface_index);

@Native<Int32 Function(Int32 fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Int32 interface_index)>(isLeaf: true)
external int transport_socket_multicast_add_membership(int fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, int interface_index);

@Native<Int32 Function(Int32 fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Int32 interface_index)>(isLeaf: true)
external int transport_socket_multicast_drop_membership(int fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, int interface_index);

@Native<Int32 Function(Int32 fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Pointer<Utf8> source_address)>(isLeaf: true)
external int transport_socket_multicast_add_source_membership(int fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Pointer<Utf8> source_address);

@Native<Int32 Function(Int32 fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Pointer<Utf8> source_address)>(isLeaf: true)
external int transport_socket_multicast_drop_source_membership(int fd, Pointer<Utf8> group_address, Pointer<Utf8> local_address, Pointer<Utf8> source_address);

@Native<Int32 Function(Pointer<Utf8> interface)>(isLeaf: true)
external int transport_socket_get_interface_index(Pointer<Utf8> interface);
