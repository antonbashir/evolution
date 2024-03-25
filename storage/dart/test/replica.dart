import 'dart:io';

import 'package:storage/storage.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main(List<String> args) => test("test replica ${args[0]}", () async {
      final workDirectory = Directory(Directory.current.path + "/test/storage_${int.parse(args[0].toString())}");
      final bootConfiguration = StorageDefaults.boot();
      final configuration = StorageDefaults.storage.copyWith(
        listen: args[0].toString(),
        replication: StorageReplicationConfiguration()
            .addAddressReplica("127.0.0.1", args[1], user: bootConfiguration.user, password: bootConfiguration.password)
            .addAddressReplica("127.0.0.1", args[2], user: bootConfiguration.user, password: bootConfiguration.password)
            .addAddressReplica("127.0.0.1", args[3], user: bootConfiguration.user, password: bootConfiguration.password)
            .format(),
        workDir: workDirectory.path,
      );
      if (workDirectory.existsSync()) {
        workDirectory.deleteSync(recursive: true);
      }
      workDirectory.createSync();
      await context().storageModule().state.waitInitialized();
      expect(context().storageModule().state.initialized(), equals(true));
      await Future.delayed(Duration(seconds: 1));
      workDirectory.deleteSync(recursive: true);
    });
