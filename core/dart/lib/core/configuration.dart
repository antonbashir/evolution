import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'context.dart';

class CoreModuleConfiguration with ModuleConfiguration {
  final bool silent;
  final EventLevel printLevel;

  const CoreModuleConfiguration({required this.printLevel, required this.silent});

  Pointer<core_module_configuration> toNative(Arena arena) {
    final native = arena<core_module_configuration>();
    native.ref.print_level = printLevel.level;
    native.ref.silent = native.ref.silent;
    return native;
  }

  factory CoreModuleConfiguration.fromNative(core_module_configuration native) => CoreModuleConfiguration(
        printLevel: EventLevel.ofLevel(native.print_level),
        silent: native.silent,
      );

  CoreModuleConfiguration copyWith({bool? silent, EventLevel? printLevel, String? component}) => CoreModuleConfiguration(
        silent: silent ?? this.silent,
        printLevel: printLevel ?? this.printLevel,
      );
}
