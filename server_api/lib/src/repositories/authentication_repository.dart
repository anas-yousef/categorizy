import 'dart:io';

import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the authentication repository
class AuthenticationRepositoryException extends ServerException {
  /// Constructor for the AuthenticationRepositoryException class
  AuthenticationRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(
          errorMessage: 'AuthenticationRepositoryException -> $errorMessage',
        );
}

/// SMS OTP authentication
class AuthenticationRepository {
  /// Constructor
  const AuthenticationRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Verify the token and return the user
  Future<User?> verifyToken(
    String accessToken,
  ) async {
    try {
      final userResponse = await supabaseClient.auth.getUser(accessToken);
      return userResponse.user;
    } on AuthException catch (authException) {
      print(authException);
      return null;
    } catch (err) {
      throw AuthenticationRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
