import 'package:core/core.dart';

import 'constants.dart';

class ExecutorException implements Exception {
  final String message;

  const ExecutorException(this.message);

  @inline
  static checkRing(int result, [void Function()? finalizer]) {
    if (result == executorErrorRingFull) {
      finalizer?.call();
      throw ExecutorException(ExecutorErrors.executorRingFullError);
    }
  }

  @override
  String toString() => "[$executorModuleName] $message";
}
