class CoreException implements Exception {
  final String message;
  final StackTrace stack;

  CoreException(this.message) : stack = StackTrace.current;

  String format() => "[core]: $message\n${stack}";

  @override
  String toString() => message;
}
