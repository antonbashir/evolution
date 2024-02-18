import '../core.dart';

class CoreModule {
  CoreModule._();

  static void load() => SystemLibrary.loadByName(coreLibraryName, corePackageName);
}
