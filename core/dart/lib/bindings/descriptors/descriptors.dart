// ignore_for_file: unused_import

import 'dart:ffi';

@Native<Void Function(Int32 fd)>(isLeaf: true)
external void system_shutdown_descriptor(int fd);
