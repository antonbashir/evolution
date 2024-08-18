import 'dart:io';

import 'package:core/core.dart';

import 'configuration.dart';
import 'constants.dart';

class StorageBootstrapScript {
  final StorageConfiguration _configuration;
  String _content = empty;
  StorageConfiguration get configuration => _configuration;

  StorageBootstrapScript(this._configuration);

  StorageBootstrapScript code(String expression) {
    _content += (expression + newLine);
    return this;
  }

  StorageBootstrapScript file(File file) {
    _content += (newLine + file.readAsStringSync() + newLine);
    return this;
  }

  StorageBootstrapScript includeLuaModulePath(String directory) => code(LuaExpressions.extendPackagePath(directory));

  StorageBootstrapScript includeNativeModulePath(String directory) => code(LuaExpressions.extendPackageNativePath(directory));

  String write() {
    if (Directory.current.listSync().whereType<Directory>().any((element) => element.path.endsWith(Directories.lua))) {
      includeLuaModulePath(Directory.current.path + Directories.lua);
    }
    if (Directory.current.listSync().whereType<Directory>().any((element) => element.path.endsWith(Directories.native))) {
      includeNativeModulePath(Directory.current.path + Directories.native);
    }
    final dartTool = findDotDartTool();
    if (dartTool != null) {
      includeLuaModulePath(Directory(findPackageRoot(dartTool, storageModuleName).toFilePath() + Directories.lua).absolute.path);
    }
    code(LuaExpressions.require(storageLuaModule));
    return _configuration.format() + newLine + _content;
  }
}
