class DuplicateKeyError implements Exception {
  final String message;
  final Exception mainException;
  const DuplicateKeyError({required this.message, required this.mainException});

  String toString() => "DuplicateKeyError: $message. Main exception: ${mainException.toString()}";
}