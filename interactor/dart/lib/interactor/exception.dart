class InteractorException implements Exception {
  final String message;

  InteractorException(this.message);

  @override
  String toString() => message;
}
