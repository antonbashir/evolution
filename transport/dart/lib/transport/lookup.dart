import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform, Directory, File;

import 'constants.dart';

class TransportLibrary {
  final DynamicLibrary library;
  final String path;

  TransportLibrary(this.library, this.path);

  factory TransportLibrary.load({String? libraryPath}) => libraryPath != null
      ? File(libraryPath).existsSync()
          ? TransportLibrary(DynamicLibrary.open(libraryPath), libraryPath)
          : _load()
      : _load();
}

TransportLibrary _load() {
  try {
    return TransportLibrary(Platform.isLinux ? DynamicLibrary.open(transportLibraryName) : throw UnsupportedError(Directory.current.path + slash + transportLibraryName),
        Directory.current.path + slash + transportLibraryName);
  } on ArgumentError {
    final dotDartTool = findDotDartTool();
    if (dotDartTool != null) {
      final packageNativeRoot = Directory(findPackageRoot(dotDartTool).toFilePath() + TransportDirectories.native);
      final libraryFile = File(packageNativeRoot.path + slash + transportLibraryName);
      if (libraryFile.existsSync()) {
        return TransportLibrary(DynamicLibrary.open(libraryFile.path), libraryFile.path);
      }
      throw UnsupportedError(loadError(libraryFile.path));
    }
    throw UnsupportedError(unableToFindProjectRoot);
  }
}