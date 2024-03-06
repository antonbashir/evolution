class ExecutorException implements Exception {
  final String message;

  ExecutorException(this.message);

  @override
  String toString() => message;
}
