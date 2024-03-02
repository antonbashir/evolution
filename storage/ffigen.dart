import 'dart:io';

void main() {
  final command = (
    executable: "dart",
    args: [
      "run",
      "ffigen",
      "--compiler-opts",
      "-I${Directory.current.absolute.parent.path}/mediator/native/include",
    ],
  );
  final result = Process.runSync(command.executable, command.args, workingDirectory: "dart");
  if (result.exitCode != 0) {
    print(result.stdout);
    print(result.stderr);
    throw Exception(command);
  }
  print(result.stdout);
  print(result.stderr);
  final file = File("dart/lib/storage/bindings.dart");
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "// ignore_for_file: type=lint",
    "// ignore_for_file: type=lint, unused_field",
  );
  file.writeAsStringSync(content);
}
