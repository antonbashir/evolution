import '../core.dart';

class Core {
  Core._();

  static void load() => SystemLibrary.loadByName(coreLibraryName, corePackageName);
}
