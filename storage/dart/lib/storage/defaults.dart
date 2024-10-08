import 'dart:io';

import 'configuration.dart';
import 'script.dart';

class StorageDefaults {
  const StorageDefaults._();

  static final StorageLaunchConfiguration launch = StorageLaunchConfiguration(
    username: "replicator",
    password: "replicator",
  );

  static final module = StorageModuleConfiguration(
    bootConfiguration: boot,
    executorConfiguration: executor,
    modules: {},
  );

  static final boot = StorageBootConfiguration(
    launchConfiguration: launch,
    initialScript: StorageBootstrapScript(storage).write(),
    binaryPath: Platform.executable,
    initializationTimeout: Duration(seconds: 30),
    shutdownTimeout: Duration(seconds: 30),
  );

  static const executor = StorageExecutorConfiguration(
    ringSize: 16384,
    ringFlags: 0,
  );

  static const storage = StorageConfiguration({
    "listen": null,
    "memtx_memory": 512 * 1024 * 1024,
    "strip_core": true,
    "memtx_min_tuple_size": 16,
    "memtx_max_tuple_size": 1024 * 1024,
    "slab_alloc_granularity": 8,
    "slab_alloc_factor": 1.05,
    "iproto_threads": 1,
    "work_dir": null,
    "memtx_dir": "'.'",
    "wal_dir": "'.'",
    "vinyl_dir": "'.'",
    "vinyl_memory": 128 * 1024 * 1024,
    "vinyl_cache": 128 * 1024 * 1024,
    "vinyl_max_tuple_size": 1024 * 1024,
    "vinyl_read_threads": 1,
    "vinyl_write_threads": 4,
    "vinyl_timeout": 60,
    "vinyl_run_count_per_level": 2,
    "vinyl_run_size_ratio": 3.5,
    "vinyl_range_size": null,
    "vinyl_page_size": 8 * 1024,
    "vinyl_bloom_fpr": 0.05,
    "io_collect_interval": null,
    "readahead": 1048576,
    "snap_io_rate_limit": null,
    "too_long_threshold": 1,
    "wal_mode": "\"write\"",
    "wal_max_size": 256 * 1024 * 1024,
    "wal_dir_rescan_delay": 2,
    "wal_queue_max_size": 16 * 1024 * 1024,
    "wal_cleanup_delay": 4 * 3600,
    "force_recovery": false,
    "replication": null,
    "instance_uuid": null,
    "replicaset_uuid": null,
    "coredump": false,
    "read_only": false,
    "hot_standby": false,
    "checkpoint_interval": 3600,
    "checkpoint_wal_threshold": 1e18,
    "checkpoint_count": 2,
    "worker_pool_threads": 4,
    "election_mode": "'off'",
    "election_timeout": 5,
    "replication_timeout": 1,
    "replication_sync_lag": 10,
    "replication_sync_timeout": 300,
    "replication_synchro_quorum": 1,
    "replication_synchro_timeout": 5,
    "replication_connect_timeout": 30,
    "replication_skip_conflict": false,
    "replication_anon": false,
    "feedback_enabled": false,
    "feedback_crashinfo": false,
    "feedback_host": null,
    "feedback_interval": 0,
    "net_msg_max": 65536,
    "sql_cache_size": 5 * 1024 * 1024,
    "log_level": 5,
  });
}
