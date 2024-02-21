import 'dart:io';

void main() {
  final process = Process.runSync("dart", ["run", "ffigen"], workingDirectory: "dart");
  if (process.exitCode != 0) {
    print(process.stdout);
    print(process.stderr);
    throw Exception("dart run ffigen");
  }
  final file = File("dart/lib/transport/bindings.dart");
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "// ignore_for_file: type=lint",
    "// ignore_for_file: type=lint, unused_field",
  );
  file.writeAsStringSync(content);
}
