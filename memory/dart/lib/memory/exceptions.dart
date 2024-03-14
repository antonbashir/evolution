import 'constants.dart';

class MemoryException implements Exception {
  final String message;

  const MemoryException(this.message);

  @override
  String toString() => "[$memoryModuleName] $message";
}
