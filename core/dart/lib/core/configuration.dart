import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'context.dart';

class CoreModuleConfiguration with ModuleConfiguration {
  final bool silent;
  final int printLevel;
  final String component;

  const CoreModuleConfiguration({required this.printLevel, required this.component, required this.silent});

  Pointer<core_module_configuration> toNative(Arena arena) {
    Pointer<core_module_configuration> native = arena();
    native.ref.print_level = printLevel;
    native.ref.component = component.toNativeUtf8(allocator: arena);
    native.ref.silent = native.ref.silent;
    return native;
  }

  factory CoreModuleConfiguration.fromNative(Pointer<core_module_configuration> native) => CoreModuleConfiguration(
        printLevel: native.ref.print_level,
        silent: native.ref.silent,
        component: native.ref.component.toDartString(),
      );

  CoreModuleConfiguration copyWith({bool? silent, int? printLevel, String? component}) => CoreModuleConfiguration(
        silent: silent ?? this.silent,
        printLevel: printLevel ?? this.printLevel,
        component: component ?? this.component,
      );
}
