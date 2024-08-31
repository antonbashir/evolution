import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'context.dart';

class SystemConfiguration {
  final bool silent;
  final EventLevel printLevel;

  const SystemConfiguration({required this.printLevel, required this.silent});

  Pointer<bootstrap_configuration> toNative(Arena arena) {
    final native = arena<bootstrap_configuration>();
    native.ref.print_level = printLevel.level;
    native.ref.silent = native.ref.silent;
    return native;
  }

  factory SystemConfiguration.fromNative(bootstrap_configuration native) => SystemConfiguration(
        printLevel: EventLevel.ofLevel(native.print_level),
        silent: native.silent,
      );

  SystemConfiguration copyWith({bool? silent, EventLevel? printLevel, String? component}) => SystemConfiguration(
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

  factory CoreModuleConfiguration.fromNative(core_module_configuration native) => CoreModuleConfiguration();
}
