import 'package:storage/storage.dart';
import 'package:test/test.dart';

import 'test.dart';

void testSchema() {
  test("schema operations", () async {
    await executor.schema.createSpace(
      "test-space",
      engine: StorageEngine.memtx,
      fieldCount: 3,
      format: [
        StorageSpaceField.string("field-1"),
        StorageSpaceField.boolean("field-2"),
        StorageSpaceField.integer("field-3"),
      ],
      id: 3,
      ifNotExists: true,
    );
    expect(tarantoolCallExtractBool(await executor.call("validateCreatedSpace")), isTrue);
    expect(await executor.schema.spaceExists("test-space"), isTrue);

    await executor.schema.createIndex(
      "test-space",
      "test-index",
      id: 0,
      ifNotExists: true,
      type: StorageIndexType.hash,
      unique: true,
      parts: [
        StorageIndexPart.byName("field-1"),
        StorageIndexPart.integer(3),
      ],
    );
    expect(tarantoolCallExtractBool(await executor.call("validateCreatedIndex")), isTrue);
    expect(await executor.schema.indexExists(3, "test-index"), isTrue);

    await executor.schema.createUser("test-user", "test-password", ifNotExists: true);
    expect(await executor.schema.userExists("test-user"), isTrue);
    await executor.schema.grantUser("test-user", "read", objectType: "space", objectName: "test", ifNotExists: true);
//  try {
//    await executor.schema.grantUser("test-user", "write", objectType: "universe");
//  } catch (error) {
//    expect(
//      error,
//      predicate((exception) => exception is StorageExecutionException && exception.toString() == "User 'test-user' already has write access on universe"),
//    );
//  }
    await executor.schema.revokeUser("test-user", "read", objectType: "space", objectName: "test", ifNotExists: true);
    await executor.schema.revokeUser("test-user", "write", objectType: "universe", ifNotExists: true);
    await executor.schema.dropUser("test-user");
    expect(await executor.schema.userExists("test-user"), isFalse);

    await executor.schema.dropIndex("test-space", "test-index");
    expect(await executor.schema.indexExists(3, "test-index"), isFalse);

    await executor.schema.dropSpace("test-space");
    expect(await executor.schema.spaceExists("test-space"), isFalse);
  });
}
