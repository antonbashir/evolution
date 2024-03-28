import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'constants.dart';
import 'extensions.dart';

class StorageModuleConfiguration implements ModuleConfiguration {
  final StorageBootConfiguration bootConfiguration;
  final StorageExecutorConfiguration executorConfiguration;
  final Set<String> modules;

  const StorageModuleConfiguration({
    required this.bootConfiguration,
    required this.executorConfiguration,
    required this.modules,
  });

  StorageModuleConfiguration copyWith({
    StorageBootConfiguration? bootConfiguration,
    StorageExecutorConfiguration? executorConfiguration,
    Set<String>? modules,
  }) =>
      StorageModuleConfiguration(
        bootConfiguration: bootConfiguration ?? this.bootConfiguration,
        executorConfiguration: executorConfiguration ?? this.executorConfiguration,
        modules: modules ?? this.modules,
      );

  Pointer<storage_module_configuration> toNative(Arena arena) {
    Pointer<storage_module_configuration> native = arena();
    native.ref.boot_configuration = bootConfiguration.toNative(arena).ref;
    native.ref.executor_configuration = executorConfiguration.toNative(arena).ref;
    return native;
  }

  factory StorageModuleConfiguration.fromNative(storage_module_configuration configuration) => StorageModuleConfiguration(
        bootConfiguration: StorageBootConfiguration.fromNative(configuration.boot_configuration),
        executorConfiguration: StorageExecutorConfiguration.fromNative(configuration.executor_configuration),
        modules: {},
      );
}

class StorageExecutorConfiguration {
  final int ringSize;
  final int ringFlags;

  const StorageExecutorConfiguration({
    required this.ringSize,
    required this.ringFlags,
  });

  StorageExecutorConfiguration copyWith({
    int? ringSize,
    int? ringFlags,
  }) =>
      StorageExecutorConfiguration(
        ringSize: ringSize ?? this.ringSize,
        ringFlags: ringFlags ?? this.ringFlags,
      );

  Pointer<storage_executor_configuration> toNative(Allocator allocator) {
    Pointer<storage_executor_configuration> configuration = allocator<storage_executor_configuration>();
    configuration.ref.ring_size = ringSize;
    configuration.ref.ring_flags = ringFlags;
    return configuration;
  }

  factory StorageExecutorConfiguration.fromNative(storage_executor_configuration native) => StorageExecutorConfiguration(
        ringSize: native.ring_size,
        ringFlags: native.ring_flags,
      );
}

class StorageBootConfiguration {
  final StorageLaunchConfiguration launchConfiguration;
  final String initialScript;
  final String binaryPath;
  final Duration initializationTimeout;
  final Duration shutdownTimeout;

  const StorageBootConfiguration({
    required this.launchConfiguration,
    required this.initialScript,
    required this.binaryPath,
    required this.initializationTimeout,
    required this.shutdownTimeout,
  });

  StorageBootConfiguration copyWith({
    StorageLaunchConfiguration? launchConfiguration,
    String? initialScript,
    String? binaryPath,
    Duration? initializationTimeout,
    Duration? shutdownTimeout,
  }) =>
      StorageBootConfiguration(
        launchConfiguration: launchConfiguration ?? this.launchConfiguration,
        initialScript: initialScript ?? this.initialScript,
        binaryPath: binaryPath ?? this.binaryPath,
        initializationTimeout: initializationTimeout ?? this.initializationTimeout,
        shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
      );

  Pointer<storage_boot_configuration> toNative(Arena arena) {
    Pointer<storage_boot_configuration> native = arena();
    native.ref.binary_path = Platform.resolvedExecutable.toNativeUtf8(allocator: arena);
    native.ref.initial_script = initialScript.toNativeUtf8(allocator: arena);
    native.ref.initialization_timeout_seconds = initializationTimeout.inSeconds;
    native.ref.shutdown_timeout_seconds = shutdownTimeout.inSeconds;
    native.ref.launch_configuration = launchConfiguration.toNative(arena).ref;
    return native;
  }

  factory StorageBootConfiguration.fromNative(storage_boot_configuration configuration) => StorageBootConfiguration(
        launchConfiguration: StorageLaunchConfiguration.fromNative(configuration.launch_configuration),
        initialScript: configuration.initial_script.toDartString(),
        binaryPath: configuration.binary_path.toDartString(),
        initializationTimeout: Duration(seconds: configuration.initialization_timeout_seconds),
        shutdownTimeout: Duration(seconds: configuration.shutdown_timeout_seconds),
      );
}

class StorageLaunchConfiguration implements Tuple {
  final String username;
  final String password;

  StorageLaunchConfiguration({required this.username, required this.password});

  StorageLaunchConfiguration copyWith({
    String? username,
    String? password,
  }) =>
      StorageLaunchConfiguration(
        username: username ?? this.username,
        password: password ?? this.password,
      );

  @override
  int serialize(Uint8List buffer, ByteData data, int offset) {
    offset = tupleWriteList(data, 2, offset);
    offset = tupleWriteString(buffer, data, username, offset);
    return tupleWriteString(buffer, data, password, offset);
  }

  factory StorageLaunchConfiguration.deserialize(Uint8List buffer, ByteData data, int offset) {
    final tuple = tupleReadList(data, offset);
    final username = tupleReadString(buffer, data, tuple.offset);
    final password = tupleReadString(buffer, data, username.offset);
    return StorageLaunchConfiguration(username: username.value!, password: password.value!);
  }

  Pointer<storage_launch_configuration> toNative(Allocator arena) {
    Pointer<storage_launch_configuration> native = arena();
    native.ref.username = username.toNativeUtf8(allocator: arena);
    native.ref.password = password.toNativeUtf8(allocator: arena);
    return native;
  }

  factory StorageLaunchConfiguration.fromNative(storage_launch_configuration native) => StorageLaunchConfiguration(
        username: native.username.toDartString(),
        password: native.password.toDartString(),
      );

  @override
  int get tupleSize => tupleSizeOfList(2) + tupleSizeOfString(username.length) + tupleSizeOfString(password.length);
}

class StorageReplicationConfiguration {
  final _replicas = <String>[];

  StorageReplicationConfiguration addAddressReplica(String host, String port, {String? user, String? password}) {
    if (user != null && user.isNotEmpty) {
      if (password != null && password.isNotEmpty) {
        addReplica("$user:$password@$host:$port");
        return this;
      }
      addReplica("$user@$host:$port");
      return this;
    }
    addReplica("$host:$port");
    return this;
  }

  StorageReplicationConfiguration addPortReplica(int port) => addReplica(port.toString());

  StorageReplicationConfiguration addReplica(String uri) => this.._replicas.add(uri.quoted);

  String format() => "$openingBracket${_replicas.join(comma)}$closingBracket";
}

class StorageConfiguration {
  final Map<String, dynamic> _configurationMap;

  const StorageConfiguration(this._configurationMap);

  String? get listen => _configurationMap[ConfigurationKeys.listen];
  int get memtxMemory => _configurationMap[ConfigurationKeys.memtxMemory];
  bool get stripCore => _configurationMap[ConfigurationKeys.stripCore];
  int get memtxMinTupleSize => _configurationMap[ConfigurationKeys.memtxMinTupleSize];
  int get memtxMaxTupleSize => _configurationMap[ConfigurationKeys.memtxMaxTupleSize];
  int get slabAllocGranularity => _configurationMap[ConfigurationKeys.slabAllocGranularity];
  double get slabAllocFactor => _configurationMap[ConfigurationKeys.slabAllocFactor];
  int get iprotoThreads => _configurationMap[ConfigurationKeys.iprotoThreads];
  String? get workDir => _configurationMap[ConfigurationKeys.workDir];
  String get memtxDir => _configurationMap[ConfigurationKeys.memtxDir];
  String get walDir => _configurationMap[ConfigurationKeys.walDir];
  String get vinylDir => _configurationMap[ConfigurationKeys.vinylDir];
  int get vinylMemory => _configurationMap[ConfigurationKeys.vinylMemory];
  int get vinylCache => _configurationMap[ConfigurationKeys.vinylCache];
  int get vinylMaxTupleSize => _configurationMap[ConfigurationKeys.vinylMaxTupleSize];
  int get vinylReadThreads => _configurationMap[ConfigurationKeys.vinylReadThreads];
  int get vinylWriteThreads => _configurationMap[ConfigurationKeys.vinylWriteThreads];
  int get vinylTimeout => _configurationMap[ConfigurationKeys.vinylTimeout];
  int get vinylRunCountPerLevel => _configurationMap[ConfigurationKeys.vinylRunCountPerLevel];
  double get vinylRunSizeRatio => _configurationMap[ConfigurationKeys.vinylRunSizeRatio];
  int? get vinylRangeSize => _configurationMap[ConfigurationKeys.vinylRangeSize];
  int get vinylPageSize => _configurationMap[ConfigurationKeys.vinylPageSize];
  double get vinylBloomFpr => _configurationMap[ConfigurationKeys.vinylBloomFpr];
  int? get ioCollectInterval => _configurationMap[ConfigurationKeys.ioCollectInterval];
  int get readahead => _configurationMap[ConfigurationKeys.readahead];
  int? get snapIoRateLimit => _configurationMap[ConfigurationKeys.snapIoRateLimit];
  double get tooLongThreshold => _configurationMap[ConfigurationKeys.tooLongThreshold];
  String get walMode => _configurationMap[ConfigurationKeys.walMode];
  int get walMaxSize => _configurationMap[ConfigurationKeys.walMaxSize];
  int get walDirRescanDelay => _configurationMap[ConfigurationKeys.walDirRescanDelay];
  int get walQueueMaxSize => _configurationMap[ConfigurationKeys.walQueueMaxSize];
  int get walCleanupDelay => _configurationMap[ConfigurationKeys.walCleanupDelay];
  bool get forceRecovery => _configurationMap[ConfigurationKeys.forceRecovery];
  String? get replication => _configurationMap[ConfigurationKeys.replication];
  String? get instanceUuid => _configurationMap[ConfigurationKeys.instanceUuid];
  String? get replicasetUuid => _configurationMap[ConfigurationKeys.replicasetUuid];
  bool get coredump => _configurationMap[ConfigurationKeys.coredump];
  bool get readOnly => _configurationMap[ConfigurationKeys.readOnly];
  bool get hotStandby => _configurationMap[ConfigurationKeys.hotStandby];
  int get checkpointInterval => _configurationMap[ConfigurationKeys.checkpointInterval];
  double get checkpointWalThreshold => _configurationMap[ConfigurationKeys.checkpointWalThreshold];
  int get checkpointCount => _configurationMap[ConfigurationKeys.checkpointCount];
  int get workerPoolThreads => _configurationMap[ConfigurationKeys.workerPoolThreads];
  String get electionMode => _configurationMap[ConfigurationKeys.electionMode];
  int get electionTimeout => _configurationMap[ConfigurationKeys.electionTimeout];
  int get replicationTimeout => _configurationMap[ConfigurationKeys.replicationTimeout];
  int get replicationSyncLag => _configurationMap[ConfigurationKeys.replicationSyncLag];
  int get replicationSyncTimeout => _configurationMap[ConfigurationKeys.replicationSyncTimeout];
  int get replicationSynchroQuorum => _configurationMap[ConfigurationKeys.replicationSynchroQuorum];
  int get replicationSynchroTimeout => _configurationMap[ConfigurationKeys.replicationSynchroTimeout];
  double get replicationConnectTimeout => _configurationMap[ConfigurationKeys.replicationConnectTimeout];
  bool get replicationSkipConflict => _configurationMap[ConfigurationKeys.replicationSkipConflict];
  bool get replicationAnon => _configurationMap[ConfigurationKeys.replicationAnon];
  bool get feedbackEnabled => _configurationMap[ConfigurationKeys.feedbackEnabled];
  bool get feedbackCrashinfo => _configurationMap[ConfigurationKeys.feedbackCrashinfo];
  String get feedbackHost => _configurationMap[ConfigurationKeys.feedbackHost];
  int get feedbackInterval => _configurationMap[ConfigurationKeys.feedbackInterval];
  int get netMsgMax => _configurationMap[ConfigurationKeys.netMsgMax];
  int get sqlCacheSize => _configurationMap[ConfigurationKeys.sqlCacheSize];
  int get logLevel => _configurationMap[ConfigurationKeys.logLevel];
  String get log => _configurationMap[ConfigurationKeys.log] ?? empty;

  StorageConfiguration copyWith({
    String? listen,
    int? memtxMemory,
    bool? stripCore,
    int? memtxMinTupleSize,
    int? memtxMaxTupleSize,
    int? slabAllocGranularity,
    double? slabAllocFactor,
    int? iprotoThreads,
    String? workDir,
    String? memtxDir,
    String? walDir,
    String? vinylDir,
    int? vinylMemory,
    int? vinylCache,
    int? vinylMaxTupleSize,
    int? vinylReadThreads,
    int? vinylWriteThreads,
    int? vinylTimeout,
    int? vinylRunCountPerLevel,
    double? vinylRunSizeRatio,
    int? vinylRangeSize,
    int? vinylPageSize,
    double? vinylBloomFpr,
    int? ioCollectInterval,
    int? readahead,
    int? snapIoRateLimit,
    double? tooLongThreshold,
    String? walMode,
    int? walMaxSize,
    int? walDirRescanDelay,
    int? walQueueMaxSize,
    int? walCleanupDelay,
    bool? forceRecovery,
    String? replication,
    String? instanceUuid,
    String? replicasetUuid,
    bool? coredump,
    bool? readOnly,
    bool? hotStandby,
    int? checkpointInterval,
    double? checkpointWalThreshold,
    int? checkpointCount,
    int? workerPoolThreads,
    String? electionMode,
    int? electionTimeout,
    int? replicationTimeout,
    int? replicationSyncLag,
    int? replicationSyncTimeout,
    int? replicationSynchroQuorum,
    int? replicationSynchroTimeout,
    double? replicationConnectTimeout,
    bool? replicationSkipConflict,
    bool? replicationAnon,
    bool? feedbackEnabled,
    bool? feedbackCrashinfo,
    String? feedbackHost,
    int? feedbackInterval,
    int? netMsgMax,
    int? sqlCacheSize,
    int? logLevel,
    String? log,
  }) {
    final copy = {..._configurationMap};
    copy[ConfigurationKeys.listen] = listen?.quoted ?? _configurationMap[ConfigurationKeys.listen];
    copy[ConfigurationKeys.memtxMemory] = memtxMemory ?? _configurationMap[ConfigurationKeys.memtxMemory];
    copy[ConfigurationKeys.stripCore] = stripCore ?? _configurationMap[ConfigurationKeys.stripCore];
    copy[ConfigurationKeys.memtxMinTupleSize] = memtxMinTupleSize ?? _configurationMap[ConfigurationKeys.memtxMinTupleSize];
    copy[ConfigurationKeys.memtxMaxTupleSize] = memtxMaxTupleSize ?? _configurationMap[ConfigurationKeys.memtxMaxTupleSize];
    copy[ConfigurationKeys.slabAllocGranularity] = slabAllocGranularity ?? _configurationMap[ConfigurationKeys.slabAllocGranularity];
    copy[ConfigurationKeys.slabAllocFactor] = slabAllocFactor ?? _configurationMap[ConfigurationKeys.slabAllocFactor];
    copy[ConfigurationKeys.iprotoThreads] = iprotoThreads ?? _configurationMap[ConfigurationKeys.iprotoThreads];
    copy[ConfigurationKeys.workDir] = workDir?.quoted ?? _configurationMap[ConfigurationKeys.workDir];
    copy[ConfigurationKeys.memtxDir] = memtxDir?.quoted ?? _configurationMap[ConfigurationKeys.memtxDir];
    copy[ConfigurationKeys.walDir] = walDir?.quoted ?? _configurationMap[ConfigurationKeys.walDir];
    copy[ConfigurationKeys.vinylDir] = vinylDir?.quoted ?? _configurationMap[ConfigurationKeys.vinylDir];
    copy[ConfigurationKeys.vinylMemory] = vinylMemory ?? _configurationMap[ConfigurationKeys.vinylMemory];
    copy[ConfigurationKeys.vinylCache] = vinylCache ?? _configurationMap[ConfigurationKeys.vinylCache];
    copy[ConfigurationKeys.vinylMaxTupleSize] = vinylMaxTupleSize ?? _configurationMap[ConfigurationKeys.vinylMaxTupleSize];
    copy[ConfigurationKeys.vinylReadThreads] = vinylReadThreads ?? _configurationMap[ConfigurationKeys.vinylReadThreads];
    copy[ConfigurationKeys.vinylWriteThreads] = vinylWriteThreads ?? _configurationMap[ConfigurationKeys.vinylWriteThreads];
    copy[ConfigurationKeys.vinylTimeout] = vinylTimeout ?? _configurationMap[ConfigurationKeys.vinylTimeout];
    copy[ConfigurationKeys.vinylRunCountPerLevel] = vinylRunCountPerLevel ?? _configurationMap[ConfigurationKeys.vinylRunCountPerLevel];
    copy[ConfigurationKeys.vinylRunSizeRatio] = vinylRunSizeRatio ?? _configurationMap[ConfigurationKeys.vinylRunSizeRatio];
    copy[ConfigurationKeys.vinylRangeSize] = vinylRangeSize ?? _configurationMap[ConfigurationKeys.vinylRangeSize];
    copy[ConfigurationKeys.vinylPageSize] = vinylPageSize ?? _configurationMap[ConfigurationKeys.vinylPageSize];
    copy[ConfigurationKeys.vinylBloomFpr] = vinylBloomFpr ?? _configurationMap[ConfigurationKeys.vinylBloomFpr];
    copy[ConfigurationKeys.ioCollectInterval] = ioCollectInterval ?? _configurationMap[ConfigurationKeys.ioCollectInterval];
    copy[ConfigurationKeys.readahead] = readahead ?? _configurationMap[ConfigurationKeys.readahead];
    copy[ConfigurationKeys.snapIoRateLimit] = snapIoRateLimit ?? _configurationMap[ConfigurationKeys.snapIoRateLimit];
    copy[ConfigurationKeys.tooLongThreshold] = tooLongThreshold ?? _configurationMap[ConfigurationKeys.tooLongThreshold];
    copy[ConfigurationKeys.walMode] = walMode ?? _configurationMap[ConfigurationKeys.walMode];
    copy[ConfigurationKeys.walMaxSize] = walMaxSize ?? _configurationMap[ConfigurationKeys.walMaxSize];
    copy[ConfigurationKeys.walDirRescanDelay] = walDirRescanDelay ?? _configurationMap[ConfigurationKeys.walDirRescanDelay];
    copy[ConfigurationKeys.walQueueMaxSize] = walQueueMaxSize ?? _configurationMap[ConfigurationKeys.walQueueMaxSize];
    copy[ConfigurationKeys.walCleanupDelay] = walCleanupDelay ?? _configurationMap[ConfigurationKeys.walCleanupDelay];
    copy[ConfigurationKeys.forceRecovery] = forceRecovery ?? _configurationMap[ConfigurationKeys.forceRecovery];
    copy[ConfigurationKeys.replication] = replication ?? _configurationMap[ConfigurationKeys.replication];
    copy[ConfigurationKeys.instanceUuid] = instanceUuid ?? _configurationMap[ConfigurationKeys.instanceUuid];
    copy[ConfigurationKeys.replicasetUuid] = replicasetUuid ?? _configurationMap[ConfigurationKeys.replicasetUuid];
    copy[ConfigurationKeys.coredump] = coredump ?? _configurationMap[ConfigurationKeys.coredump];
    copy[ConfigurationKeys.readOnly] = readOnly ?? _configurationMap[ConfigurationKeys.readOnly];
    copy[ConfigurationKeys.hotStandby] = hotStandby ?? _configurationMap[ConfigurationKeys.hotStandby];
    copy[ConfigurationKeys.checkpointInterval] = checkpointInterval ?? _configurationMap[ConfigurationKeys.checkpointInterval];
    copy[ConfigurationKeys.checkpointWalThreshold] = checkpointWalThreshold ?? _configurationMap[ConfigurationKeys.checkpointWalThreshold];
    copy[ConfigurationKeys.checkpointCount] = checkpointCount ?? _configurationMap[ConfigurationKeys.checkpointCount];
    copy[ConfigurationKeys.workerPoolThreads] = workerPoolThreads ?? _configurationMap[ConfigurationKeys.workerPoolThreads];
    copy[ConfigurationKeys.electionMode] = electionMode?.quoted ?? _configurationMap[ConfigurationKeys.electionMode];
    copy[ConfigurationKeys.electionTimeout] = electionTimeout ?? _configurationMap[ConfigurationKeys.electionTimeout];
    copy[ConfigurationKeys.replicationTimeout] = replicationTimeout ?? _configurationMap[ConfigurationKeys.replicationTimeout];
    copy[ConfigurationKeys.replicationSyncLag] = replicationSyncLag ?? _configurationMap[ConfigurationKeys.replicationSyncLag];
    copy[ConfigurationKeys.replicationSyncTimeout] = replicationSyncTimeout ?? _configurationMap[ConfigurationKeys.replicationSyncTimeout];
    copy[ConfigurationKeys.replicationSynchroQuorum] = replicationSynchroQuorum ?? _configurationMap[ConfigurationKeys.replicationSynchroQuorum];
    copy[ConfigurationKeys.replicationSynchroTimeout] = replicationSynchroTimeout ?? _configurationMap[ConfigurationKeys.replicationSynchroTimeout];
    copy[ConfigurationKeys.replicationConnectTimeout] = replicationConnectTimeout ?? _configurationMap[ConfigurationKeys.replicationConnectTimeout];
    copy[ConfigurationKeys.replicationSkipConflict] = replicationSkipConflict ?? _configurationMap[ConfigurationKeys.replicationSkipConflict];
    copy[ConfigurationKeys.replicationAnon] = replicationAnon ?? _configurationMap[ConfigurationKeys.replicationAnon];
    copy[ConfigurationKeys.feedbackEnabled] = feedbackEnabled ?? _configurationMap[ConfigurationKeys.feedbackEnabled];
    copy[ConfigurationKeys.feedbackCrashinfo] = feedbackCrashinfo ?? _configurationMap[ConfigurationKeys.feedbackCrashinfo];
    copy[ConfigurationKeys.feedbackHost] = feedbackHost?.quoted ?? _configurationMap[ConfigurationKeys.feedbackHost];
    copy[ConfigurationKeys.feedbackInterval] = feedbackInterval ?? _configurationMap[ConfigurationKeys.feedbackInterval];
    copy[ConfigurationKeys.netMsgMax] = netMsgMax ?? _configurationMap[ConfigurationKeys.netMsgMax];
    copy[ConfigurationKeys.sqlCacheSize] = sqlCacheSize ?? _configurationMap[ConfigurationKeys.sqlCacheSize];
    copy[ConfigurationKeys.logLevel] = logLevel ?? _configurationMap[ConfigurationKeys.logLevel];
    copy[ConfigurationKeys.log] = log ?? _configurationMap[ConfigurationKeys.log];
    return StorageConfiguration(copy);
  }

  String format() =>
      LuaExpressions.boxCfg +
      LuaArgument.singleTableArgument(_configurationMap.entries.where((entry) => entry.value != null).map((entry) => LuaField.stringField(entry.key, entry.value.toString())).join(comma));
}
