import 'dart:io';

void main(List<String> args) {
  final current = Platform.script.path.substring(0, Platform.script.path.lastIndexOf('/'));
  if (args.isNotEmpty) {
    final process = Process.runSync("dart", ["run", "$current/infrastructure/dart/generators/bindings.dart"], workingDirectory: '$current/${args.first}');
    if ((process.stdout.toString()).isNotEmpty) print(process.stdout);
    if ((process.stderr.toString()).isNotEmpty) print(process.stderr);
    return;
  }
  Directory.current.listSync().forEach((element) {
    if (element.statSync().type == FileSystemEntityType.directory) {
      if ((element as Directory).listSync().any((element) => element.path.endsWith("native"))) {
        final process = Process.runSync("dart", ["run", "$current/infrastructure/dart/generators/bindings.dart"], workingDirectory: element.path);
        if ((process.stdout.toString()).isNotEmpty) print(process.stdout);
        if ((process.stderr.toString()).isNotEmpty) print(process.stderr);
      }
    }
  });
}
