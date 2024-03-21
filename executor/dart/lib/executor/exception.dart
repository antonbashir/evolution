import 'constants.dart';

class ExecutorModuleError extends Error {
  final String message;

  ExecutorModuleError(this.message);

  @override
  String toString() => "[$executorModuleName] $message";
}
