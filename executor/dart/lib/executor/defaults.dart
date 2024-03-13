import 'configuration.dart';

class ExecutorDefaults {
  ExecutorDefaults._();

  static const ExecutorConfiguration executor = ExecutorConfiguration(
    staticBuffersCapacity: 4096,
    staticBufferSize: 4096,
    ringSize: 16384,
    ringFlags: 0,
    memorySlabSize: 64 * 1024,
    memoryPreallocationSize: 64 * 1024,
    memoryQuotaSize: 16 * 1024 * 1024,
  );

  static const ExecutorNotifierConfiguration notifier = ExecutorNotifierConfiguration(
    ringSize: 16384,
    ringFlags: 0,
    initializationTimeout: Duration(seconds: 5),
    shutdownTimeout: Duration(seconds: 5),
  );
}
