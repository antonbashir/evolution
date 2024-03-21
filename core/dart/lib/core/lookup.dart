import 'dart:convert';
import 'dart:io';

import 'constants.dart';
import 'errors.dart';

Uri? findDotDartTool() {
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

Uri findPackageRoot(Uri dotDartTool, String packageName) {
  final packageConfigFile = File.fromUri(dotDartTool.resolve(packageConfigJsonFile));
  dynamic packageConfig;
  try {
    packageConfig = json.decode(packageConfigFile.readAsStringSync());
  } catch (ignore) {
    throw CoreModuleError(CoreErrors.unableToFindProjectRoot);
  }
  final package = (packageConfig[PackageConfigFields.packages] ?? []).firstWhere(
    (element) => element[PackageConfigFields.name] == packageName,
    orElse: () => throw CoreModuleError(CoreErrors.unableToFindProjectRoot),
  );
  return packageConfigFile.uri.resolve(package[PackageConfigFields.rootUri] ?? empty);
}

String? findProjectRoot() {
  var directory = Directory.current.path;
  while (true) {
    if (File(directory + slash + pubspecYamlFile).existsSync() || File(directory + slash + pubspecYmlFile).existsSync()) return directory;
    final String parent = Directory(directory).parent.path;
    if (directory == parent) return null;
    directory = parent;
  }
}
