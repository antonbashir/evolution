import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'constants.dart';
import 'exceptions.dart';
import 'lookup.dart';
import 'system.dart';

class SystemLibrary {
  final DynamicLibrary library;
  final String path;
  final Pointer<Void> _handle;

  SystemLibrary(this.library, this.path) : _handle = using((Arena arena) => dlopen(path.toNativeUtf8(allocator: arena).cast(), rtldGlobal | rtldLazy));

  void unload() => dlclose(_handle);

  SystemLibrary reload() {
    unload();
    return SystemLibrary.loadByPath(path);
  }

  factory SystemLibrary.loadByName(String libraryName, String packageName) {
    try {
      return SystemLibrary(
        Platform.isLinux ? DynamicLibrary.open(libraryName) : throw CoreException(CoreErrors.nonLinuxError),
        Directory.current.path + slash + libraryName,
      );
    } on ArgumentError {
      final dotDartTool = _findDotDartTool();
      if (dotDartTool != null) {
        final packageNativeRoot = Directory(findPackageRoot(dotDartTool, packageName).toFilePath() + SourcesDirectories.assets);
        final libraryFile = File(packageNativeRoot.path + slash + libraryName);
        if (libraryFile.existsSync()) {
          return SystemLibrary(DynamicLibrary.open(libraryFile.path), libraryFile.path);
        }
        throw CoreException(CoreErrors.systemLibraryLoadError(libraryFile.path));
      }
      throw CoreException(CoreErrors.unableToFindProjectRoot);
    }
  }
  factory SystemLibrary.loadByPath(String libraryPath) =>
      File(libraryPath).existsSync() ? SystemLibrary(DynamicLibrary.open(libraryPath), libraryPath) : throw CoreException(CoreErrors.systemLibraryLoadError(libraryPath));

  static Uri? _findDotDartTool() {
    Uri root = Platform.script.resolve(currentDirectorySymbol);

    do {
      if (File.fromUri(root.resolve(SourcesDirectories.dotDartTool + slash + packageConfigJsonFile)).existsSync()) {
        return root.resolve(SourcesDirectories.dotDartTool + slash);
      }
    } while (root != (root = root.resolve(parentDirectorySymbol)));

    root = Directory.current.uri;

    do {
      if (File.fromUri(root.resolve(SourcesDirectories.dotDartTool + slash + packageConfigJsonFile)).existsSync()) {
        return root.resolve(SourcesDirectories.dotDartTool + slash);
      }
    } while (root != (root = root.resolve(parentDirectorySymbol)));

    return null;
  }
}
