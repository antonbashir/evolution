import 'dart:io';

void main(List<String> args) {
  if (args.isNotEmpty) {
    final process = Process.runSync("dart", ["run", "../infrastructure/dart/bindings.dart"], workingDirectory: Directory.current.path + '/${args.first}');
    if ((process.stdout.toString()).isNotEmpty) print(process.stdout);
    if ((process.stderr.toString()).isNotEmpty) print(process.stderr);
    return;
  }
  Directory.current.listSync().forEach((element) {
    if (element.statSync().type == FileSystemEntityType.directory) {
      if ((element as Directory).listSync().any((element) => element.path.endsWith("native"))) {
        final process = Process.runSync("dart", ["run", "../infrastructure/dart/bindings.dart"], workingDirectory: element.path);
        if ((process.stdout.toString()).isNotEmpty) print(process.stdout);
        if ((process.stderr.toString()).isNotEmpty) print(process.stderr);
      }
    }
  });
}
