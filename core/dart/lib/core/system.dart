import 'dart:ffi';

import '../core.dart';
import 'bindings.dart';
import 'constants.dart';

const rtldLazy = 0x00001;
const rtldGlobal = 0x00100;

@Native<Int Function(Pointer<Void>)>()
external int dlclose(Pointer<Void> handle);

@Native<Pointer<Void> Function(Pointer<Char>, Int)>()
external Pointer<Void> dlopen(Pointer<Char> file, int mode);

@inline
String systemError(code) => "code = $code, message = ${SystemErrors.of(-code)}";

@inline
void systemShutdownDescriptor(int descriptor) => system_shutdown_descriptor(descriptor);

void main(List<String> args) {
  CoreModule.load();
  systemShutdownDescriptor(123);
}
