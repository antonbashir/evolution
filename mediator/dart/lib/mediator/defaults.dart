import 'configuration.dart';

class MediatorDefaults {
  MediatorDefaults._();

  static const MediatorConfiguration mediator = MediatorConfiguration(
    staticBuffersCapacity: 4096,
    staticBufferSize: 4096,
    ringSize: 16384,
    ringFlags: 0,
    maximumWakingTime: Duration(milliseconds: 5),
    completionPeekCount: 1024,
    completionWaitCount: 1,
    completionWaitTimeout: Duration(milliseconds: 1),
    memorySlabSize: 64 * 1024,
    memoryPreallocationSize: 64 * 1024,
    memoryQuotaSize: 16 * 1024 * 1024,
  );

  static const MediatorNotifierConfiguration notifier = MediatorNotifierConfiguration(
    ringSize: 16384,
    ringFlags: 0,
    initializationTimeout: Duration(seconds: 5),
    shutdownTimeout: Duration(seconds: 5),
  );
}