class MemoryException implements Exception {
  final String message;
  final StackTrace stack;

  MemoryException(this.message) : stack = StackTrace.current;

  String format() => "[memory]: ${message}\n${stack}";

  @override
  String toString() => message;
}