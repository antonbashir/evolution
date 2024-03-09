import 'dart:ffi';

import '../bindings/bindings.dart';

class CoreModuleConfiguration {
  final int printLevel;

  CoreModuleConfiguration({required this.printLevel});

  Pointer<core_module_configuration> toNative(Pointer<core_module_configuration> native) {
    native.ref.print_level = printLevel;
    return native;
  }

  factory CoreModuleConfiguration.fromNative(Pointer<core_module_configuration> native) => CoreModuleConfiguration(printLevel: native.ref.print_level);
}
