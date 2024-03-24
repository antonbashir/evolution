import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final current = Platform.script.path.substring(0, Platform.script.path.lastIndexOf('/'));
  final build = Process.runSync(
    "/usr/bin/cmake",
    ["--build", "${current}", "--config", "RelWithDebInfo", "--target", "natives", "-j", Platform.numberOfProcessors.toString(), "--"],
    workingDirectory: current,
  );
  stdout.writeln(build.stdout);
  stderr.writeln(build.stderr);
  final tests = {
    "memory": "$current/memory/test/test.dart",
    "executor": "$current/executor/test/dart/lib/test.dart",
    "transport": "$current/transport/test/test.dart",
    "reactive": "$current/reactive/test/test.dart",
  };
  final results = tests.map((key, value) => MapEntry(key, false));
  if (build.exitCode == 0) {
    for (var entry in tests.entries) {
      print("Running tests: ${entry.value}");
      final test = await Process.start("/usr/bin/dart", ["run", "--enable-asserts", "-DDEBUG=true", entry.value], workingDirectory: "$current/${entry.key}");
      utf8.decoder.bind(test.stdout).listen(stdout.write);
      utf8.decoder.bind(test.stderr).listen(stderr.write);
      results[entry.key] = await test.exitCode == 0;
    }
  }
  for (var entry in results.entries) {
    if (entry.value) {
      print("Tests passed for module: ${entry.key}");
      continue;
    }
    print("Tests failed for module: ${entry.key}");
  }
  if (results.values.every((element) => element)) {
    print("All modules tests passed!");
  }
}
