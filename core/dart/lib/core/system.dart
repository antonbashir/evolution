import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';

const rtldLazy = 0x00001;
const rtldGlobal = 0x00100;

@Native<Int Function(Pointer<Void>)>()
external int dlclose(Pointer<Void> handle);

@Native<Pointer<Void> Function(Pointer<Char>, Int)>()
external Pointer<Void> dlopen(Pointer<Char> file, int mode);

String systemError(int code) => system_dart_error_to_string(code).cast<Utf8>().toDartString();
void systemShutdownDescriptor(int code, int descriptor) => system_dart_close_descriptor(descriptor);
