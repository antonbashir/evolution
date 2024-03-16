import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../core.dart';
import 'exceptions.dart';

final Map<String, SystemLibrary> _loadedByName = {};
final Map<String, SystemLibrary> _loadedByPath = {};

class SystemLibrary {
  final DynamicLibrary library;
  final String name;
  final String path;
  final Pointer<Void> _handle;

  SystemLibrary(this.library, this.name, this.path) : _handle = using((Arena arena) => dlopen(path.toNativeUtf8(allocator: arena), rtldGlobal | rtldLazy)) {
    if (SystemEnvironment.debug) {
      print(CoreMessages.loadingLibrary(name, path));
    }
  }

  void unload() {
    dlclose(_handle);
    _loadedByName.remove(name);
    _loadedByPath.remove(path);
  }

  SystemLibrary reload() {
    unload();
    return SystemLibrary.loadByPath(path);
  }

  factory SystemLibrary.loadByName(String libraryName, String packageName) {
    if (_loadedByName.containsKey(libraryName)) return _loadedByName[libraryName]!;
    try {
      final library = SystemLibrary(
        Platform.isLinux ? DynamicLibrary.open(libraryName) : throw CoreException(CoreErrors.nonLinuxError),
        libraryName,
        Directory.current.path + slash + libraryName,
      );
      _loadedByName[libraryName] = library;
      return library;
    } on ArgumentError {
      final dotDartTool = _findDotDartTool();
      if (dotDartTool != null) {
        final packageNativeRoot = Directory(findPackageRoot(dotDartTool, packageName).toFilePath() + SourcesDirectories.assets);
        final libraryFile = File(packageNativeRoot.path + slash + libraryName);
        if (libraryFile.existsSync()) {
          return SystemLibrary(DynamicLibrary.open(libraryFile.path), libraryName, libraryFile.path);
        }
        throw CoreException(CoreErrors.systemLibraryLoadError(libraryFile.path));
      }
      throw CoreException(CoreErrors.unableToFindProjectRoot);
    }
  }

  factory SystemLibrary.loadByPath(String libraryPath) {
    if (_loadedByPath.containsKey(libraryPath)) return _loadedByPath[libraryPath]!;
    final library = File(libraryPath).existsSync()
        ? SystemLibrary(DynamicLibrary.open(libraryPath), libraryPath.substring(libraryPath.lastIndexOf(slash), libraryPath.length), libraryPath)
        : throw CoreException(CoreErrors.systemLibraryLoadError(libraryPath));
    _loadedByPath[libraryPath] = library;
    return library;
  }

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
