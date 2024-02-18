class MemoryRuntimeException implements Exception {
  final String message;

  MemoryRuntimeException(this.message);

  @override
  String toString() => message;
}
