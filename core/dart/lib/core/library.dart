import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'errors.dart';
import 'lookup.dart';

SystemLibrary? _core;

class SystemLibrary {
  final String path;
  final String module;
  final Pointer<system_library> handle;

  SystemLibrary(this.path, this.module, this.handle) {
    if (handle == nullptr) {
      if (dlerror() != nullptr) throw CoreModuleError(dlerror().toDartString());
      throw CoreModuleError(CoreErrors.systemLibraryLoadError(path));
    }
  }

  SystemLibrary.load(this.handle)
      : path = handle.ref.path.toDartString(),
        module = handle.ref.module.toDartString();

  factory SystemLibrary.loadByName(String libraryName, String moduleName, {bool managed = false}) {
    var native = using((arena) => system_library_load((Directory.current.path + slash + libraryName).toNativeUtf8(allocator: arena), moduleName.toNativeUtf8(allocator: arena)));
    if (native != nullptr) {
      return SystemLibrary(native.ref.path.toDartString(), moduleName, native);
    }
    final dotDartTool = findDotDartTool();
    if (dotDartTool != null) {
      final packageNativeRoot = Directory(findPackageRoot(dotDartTool, moduleName).toFilePath() + SourcesDirectories.assets);
      final libraryFile = File(packageNativeRoot.path + slash + libraryName);
      if (libraryFile.existsSync()) {
        native = using((arena) => system_library_load(libraryFile.path.toNativeUtf8(allocator: arena), moduleName.toNativeUtf8(allocator: arena)));
        if (native != nullptr) {
          return SystemLibrary(native.ref.path.toDartString(), moduleName, native);
        }
        if (dlerror() != nullptr) throw CoreModuleError(dlerror().toDartString());
        throw CoreModuleError(CoreErrors.systemLibraryLoadError(libraryFile.path));
      }
      throw CoreModuleError(CoreErrors.systemLibraryLoadError(libraryFile.path));
    }
    throw CoreModuleError(CoreErrors.unableToFindProjectRoot);
  }

  factory SystemLibrary.loadByPath(String libraryPath, String moduleName) => File(libraryPath).existsSync()
      ? SystemLibrary(libraryPath, moduleName, using((arena) => system_library_load(libraryPath.toNativeUtf8(allocator: arena), moduleName.toNativeUtf8(allocator: arena))))
      : throw CoreModuleError(CoreErrors.systemLibraryLoadError(libraryPath));

  void unload() {
    system_library_unload(handle);
  }

  SystemLibrary reload() {
    unload();
    return SystemLibrary.loadByPath(path, module);
  }

  static SystemLibrary loadCore() {
    if (_core != null) return _core!;
    var native = using((arena) => dlopen((Directory.current.path + slash + coreLibraryName).toNativeUtf8(allocator: arena), rtldGlobal | rtldLazy));
    if (native != nullptr) {
      final library = calloc<system_library>();
      library.ref.handle = native;
      library.ref.module = coreModuleName.toNativeUtf8();
      library.ref.path = (Directory.current.path + slash + coreLibraryName).toNativeUtf8();
      _core = SystemLibrary(Directory.current.path + slash + coreLibraryName, coreModuleName, library);
      return _core!;
    }
    final dotDartTool = findDotDartTool();
    if (dotDartTool != null) {
      final packageNativeRoot = Directory(findPackageRoot(dotDartTool, corePackageName).toFilePath() + SourcesDirectories.assets);
      final libraryFile = File(packageNativeRoot.path + slash + coreLibraryName);
      if (libraryFile.existsSync()) {
        native = using((arena) => dlopen(libraryFile.path.toNativeUtf8(allocator: arena), rtldGlobal | rtldLazy));
        if (native != nullptr) {
          final library = calloc<system_library>();
          library.ref.handle = native;
          library.ref.module = coreModuleName.toNativeUtf8();
          library.ref.path = (libraryFile.path).toNativeUtf8();
          _core = SystemLibrary(libraryFile.path, coreModuleName, library);
          return _core!;
        }
        if (dlerror() != nullptr) throw CoreModuleError(dlerror().toDartString());
        throw CoreModuleError(CoreErrors.systemLibraryLoadError(libraryFile.path));
      }
      throw CoreModuleError(CoreErrors.systemLibraryLoadError(libraryFile.path));
    }
    throw CoreModuleError(CoreErrors.unableToFindProjectRoot);
  }
}
