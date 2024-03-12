// ignore_for_file: unused_import

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../transport/bindings.dart';

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
