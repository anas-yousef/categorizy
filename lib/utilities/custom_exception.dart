class CustomException implements Exception {
  final String message;
  final Exception mainException;
  const CustomException({required this.message, required this.mainException});

  String toString() => "CustomException: $message. Main exception: ${mainException.toString()}";
}
