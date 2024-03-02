class MediatorException implements Exception {
  final String message;

  MediatorException(this.message);

  @override
  String toString() => message;
}
