import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'context.dart';

class CoreModuleConfiguration with ModuleConfiguration {
  final int printLevel;
  final String component;

  const CoreModuleConfiguration({required this.printLevel, required this.component});

  Pointer<core_module_configuration> toNative(Arena arena) {
    Pointer<core_module_configuration> native = arena();
    native.ref.print_level = printLevel;
    native.ref.component = component.toNativeUtf8(allocator: arena);
    return native;
  }

  factory CoreModuleConfiguration.fromNative(Pointer<core_module_configuration> native) => CoreModuleConfiguration(
        printLevel: native.ref.print_level,
        component: native.ref.component.toDartString(),
      );

  CoreModuleConfiguration copyWith({int? printLevel, String? component}) => CoreModuleConfiguration(
        printLevel: printLevel ?? this.printLevel,
        component: component ?? this.component,
      );
}
