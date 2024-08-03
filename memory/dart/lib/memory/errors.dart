import 'constants.dart';

class MemoryModuleError extends Error {
  final String message;

  MemoryModuleError(this.message);

  @override
  String toString() => "[$memoryModuleName] $message";
}
