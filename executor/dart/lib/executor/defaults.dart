import 'configuration.dart';

class ExecutorDefaults {
  ExecutorDefaults._();

  static const ExecutorModuleConfiguration module = ExecutorModuleConfiguration(scheduler);

  static const ExecutorConfiguration executor = ExecutorConfiguration(
    ringSize: 16384,
    ringFlags: 0,
  );

  static const ExecutorSchedulerConfiguration scheduler = ExecutorSchedulerConfiguration(
    ringSize: 16384,
    ringFlags: 0,
    initializationTimeout: Duration(seconds: 5),
    shutdownTimeout: Duration(seconds: 5),
  );
}
