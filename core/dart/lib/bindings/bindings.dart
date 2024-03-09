import 'dart:ffi';

const rtldLazy = 0x00001;
const rtldGlobal = 0x00100;

final class iovec extends Struct {
  external Pointer<Void> iov_base;

  @Size()
  external int iov_len;
}

final class core_module_configuration extends Struct {
  @Uint8()
  external int print_level;
}

@Native<Int Function(Pointer<Void>)>()
external int dlclose(Pointer<Void> handle);

@Native<Pointer<Void> Function(Pointer<Char>, Int)>()
external Pointer<Void> dlopen(Pointer<Char> file, int mode);

@Native<Void Function(Int32)>(isLeaf: true)
external void system_shutdown_descriptor(int fd);

@Native<Void Function(Pointer<core_module_configuration>)>(isLeaf: true)
external void core_initialize(Pointer<core_module_configuration> configuration);