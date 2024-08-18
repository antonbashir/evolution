import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'crud.dart';
import 'lua.dart';
import 'schema.dart';

late final Storage storage;
late final StorageSpace space;
late final StorageIndex index;

FutureOr<void> runTest(FutureOr<void> Function() test, {List<Module>? overrides}) => launch(
      () =>
          overrides ??
          [
            CoreModule(),
            MemoryModule(),
            ExecutorModule(),
            StorageModule(
              configuration: StorageDefaults.module.copyWith(
                bootConfiguration: StorageDefaults.module.bootConfiguration.copyWith(
                  initialScript: StorageBootstrapScript(StorageDefaults.storage).file(File(path.dirname(Platform.script.path) + '/test.lua')).write(),
                ),
              ),
            ),
          ],
      test,
    );

Future<void> main() async {
  Directory.current.listSync().forEach((element) {
    if (element.path.contains("00000")) element.deleteSync();
  });

  await runTest(() async {
    setUpAll(() async {
      storage = context().storage();
      final spaceId = await storage.schema.spaceId("test");
      space = storage.schema.spaceById(spaceId);
      index = storage.schema.indexById(spaceId, await storage.schema.indexId(spaceId, "test"));
    });
    setUp(() async => await space.truncate());
    tearDownAll(() async {
      Directory.current.listSync().forEach((element) {
        if (element.path.contains("00000")) element.deleteSync();
      });
      unblock();
    });

    test("[lua]", testLua);
    group(["schema"], testSchema);
    group("[crud]", testCrud);
    group(
      "[replication]",
      () {
        test("run", () async {
          final compilation = await Process.start(
            Platform.executable,
            ["compile", "exe", "replica.dart"],
            runInShell: false,
            workingDirectory: Directory.current.path + "/test",
          );
          expect(
            await compilation.exitCode,
            equals(0),
          );

          Process printProcess(Process process) {
            process.stderr.map(utf8.decode).forEach(Printer.printError);
            process.stdout.map(utf8.decode).forEach(Printer.printOut);
            return process;
          }

          final replicas = [
            Process.start(
              Directory.current.path + "/test/replica.exe",
              ["3303", "3303", "3304", "3305"],
              workingDirectory: Directory.current.path + "/test",
            ).then(printProcess),
            Process.start(
              Directory.current.path + "/test/replica.exe",
              ["3304", "3303", "3304", "3305"],
              workingDirectory: Directory.current.path + "/test",
            ).then(printProcess),
            Process.start(
              Directory.current.path + "/test/replica.exe",
              ["3305", "3303", "3304", "3305"],
              workingDirectory: Directory.current.path + "/test",
            ).then(printProcess),
          ];
          final results = await Future.wait((await Future.wait(replicas)).map((process) => process.exitCode));
          results.forEach((result) => expect(result, equals(0)));
        });
      },
    );
    await block();
  });
}
