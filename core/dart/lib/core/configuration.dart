import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'context.dart';

class BootstrapConfiguration {
  final bool silent;
  final EventLevel printLevel;

  const BootstrapConfiguration({required this.printLevel, required this.silent});

  Pointer<bootstrap_configuration> toNative(Arena arena) {
    final native = arena<bootstrap_configuration>();
    native.ref.print_level = printLevel.level;
    native.ref.silent = native.ref.silent;
    return native;
  }

  factory BootstrapConfiguration.fromNative(bootstrap_configuration native) => BootstrapConfiguration(
        printLevel: EventLevel.ofLevel(native.print_level),
        silent: native.silent,
      );

  BootstrapConfiguration copyWith({bool? silent, EventLevel? printLevel, String? component}) => BootstrapConfiguration(
        silent: silent ?? this.silent,
        printLevel: printLevel ?? this.printLevel,
      );
}

class CoreModuleConfiguration with ModuleConfiguration {
  const CoreModuleConfiguration();

    Pointer<core_module_configuration> toNative(Arena arena) {
    final native = arena<core_module_configuration>();
    return native;
  }

  factory CoreModuleConfiguration.fromNative(core_module_configuration native) => CoreModuleConfiguration(
      );

}
