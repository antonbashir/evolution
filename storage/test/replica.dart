import 'dart:io';

import 'package:storage/storage.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

Future<void> main(List<String> args) async {
  final workDirectory = Directory(Directory.current.path + "/storage_${int.parse(args[0].toString())}");
  if (workDirectory.existsSync()) {
    workDirectory.deleteSync(recursive: true);
  }
  workDirectory.createSync();
  await launch(
    () => [
      CoreModule(),
      MemoryModule(),
      ExecutorModule(),
      StorageModule(
        configuration: StorageDefaults.module.copyWith(
          bootConfiguration: StorageDefaults.module.bootConfiguration.copyWith(
            initialScript: StorageBootstrapScript(
              StorageDefaults.storage.copyWith(
                listen: args[0].toString(),
                replication: StorageReplicationConfiguration()
                    .addAddressReplica("127.0.0.1", args[1], user: StorageDefaults.boot.launchConfiguration.username, password: StorageDefaults.boot.launchConfiguration.password)
                    .addAddressReplica("127.0.0.1", args[2], user: StorageDefaults.boot.launchConfiguration.username, password: StorageDefaults.boot.launchConfiguration.password)
                    .addAddressReplica("127.0.0.1", args[3], user: StorageDefaults.boot.launchConfiguration.username, password: StorageDefaults.boot.launchConfiguration.password)
                    .format(),
                workDir: Directory(Directory.current.path + "/storage_${int.parse(args[0].toString())}").path,
              ),
            ).write(),
          ),
        ),
      ),
    ],
    () async {
      tearDownAll(unblock);
      test("test replica ${args[0]}", () async {
        await context().storageModule().state.waitInitialized();
        expect(context().storageModule().state.initialized(), equals(true));
        await Future.delayed(Duration(seconds: 1));
        workDirectory.deleteSync(recursive: true);
      });
      await block();
    },
  );
}
