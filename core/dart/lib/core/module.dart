import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../core.dart';
import 'configuration.dart';

class CoreModule {
  CoreModule(CoreModuleConfiguration configuration) {
    load();
    using((Arena arena) => core_initialize(configuration.toNative(arena<core_module_configuration>())));
  }

  static void load() => SystemLibrary.loadByName(coreLibraryName, corePackageName);
}
