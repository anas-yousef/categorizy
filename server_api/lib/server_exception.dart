/// A general exception class used to handle error messages on the server side
class ServerException implements Exception {
  /// Constructor
  const ServerException({
    required this.errorMessage,
    this.errorBody,
  });

  /// The error message received
  final String errorMessage;

  /// An error body if available
  final Map<String, dynamic>? errorBody;

  @override
  String toString() {
    return 'ServerException -> $errorMessage';
  }
}
