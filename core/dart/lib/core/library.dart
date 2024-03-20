import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'exceptions.dart';
import 'lookup.dart';

class SystemLibrary {
  final String path;
  final Pointer<system_library> _handle;

  SystemLibrary(this.path, this._handle) {
    if (_handle == nullptr) {
      if (dlerror() != nullptr) throw CoreException(dlerror().toDartString());
      throw CoreException(CoreErrors.systemLibraryLoadError(path));
    }
  }

  void unload() {
    system_library_unload(_handle);
  }

  SystemLibrary reload() {
    unload();
    return SystemLibrary.loadByPath(path);
  }

  factory SystemLibrary.loadByName(String libraryName, String packageName, {bool managed = false}) {
    var native = using((arena) => system_library_load((Directory.current.path + slash + libraryName).toNativeUtf8(allocator: arena)));
    if (native != nullptr) {
      return SystemLibrary(native.ref.path.toDartString(), native);
    }
    final dotDartTool = findDotDartTool();
    if (dotDartTool != null) {
      final packageNativeRoot = Directory(findPackageRoot(dotDartTool, packageName).toFilePath() + SourcesDirectories.assets);
      final libraryFile = File(packageNativeRoot.path + slash + libraryName);
      if (libraryFile.existsSync()) {
        native = using((arena) => system_library_load(libraryFile.path.toNativeUtf8(allocator: arena)));
        if (native != nullptr) {
          return SystemLibrary(native.ref.path.toDartString(), native);
        }
        if (dlerror() != nullptr) throw CoreException(dlerror().toDartString());
        throw CoreException(CoreErrors.systemLibraryLoadError(libraryFile.path));
      }
      throw CoreException(CoreErrors.systemLibraryLoadError(libraryFile.path));
    }
    throw CoreException(CoreErrors.unableToFindProjectRoot);
  }

  factory SystemLibrary.loadByPath(String libraryPath) => File(libraryPath).existsSync()
      ? SystemLibrary(libraryPath, using((arena) => system_library_load(libraryPath.toNativeUtf8(allocator: arena))))
      : throw CoreException(CoreErrors.systemLibraryLoadError(libraryPath));

  static loadCore() {
    var native = using((arena) => dlopen((Directory.current.path + slash + coreLibraryName).toNativeUtf8(allocator: arena), rtldGlobal | rtldLazy));
    if (native != nullptr) {
      return;
    }
    final dotDartTool = findDotDartTool();
    if (dotDartTool != null) {
      final packageNativeRoot = Directory(findPackageRoot(dotDartTool, corePackageName).toFilePath() + SourcesDirectories.assets);
      final libraryFile = File(packageNativeRoot.path + slash + coreLibraryName);
      if (libraryFile.existsSync()) {
        native = using((arena) => dlopen(libraryFile.path.toNativeUtf8(allocator: arena), rtldGlobal | rtldLazy));
        if (native != nullptr) {
          return;
        }
        if (dlerror() != nullptr) throw CoreException(dlerror().toDartString());
        throw CoreException(CoreErrors.systemLibraryLoadError(libraryFile.path));
      }
      throw CoreException(CoreErrors.systemLibraryLoadError(libraryFile.path));
    }
    throw CoreException(CoreErrors.unableToFindProjectRoot);
  }
}
