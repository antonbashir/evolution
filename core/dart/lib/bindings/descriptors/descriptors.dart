import 'dart:ffi';

@Native<Void Function(Int32)>(isLeaf: true)
external void system_shutdown_descriptor(int fd);
