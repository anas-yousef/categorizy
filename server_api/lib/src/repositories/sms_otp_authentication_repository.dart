import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the authentication repository
class SMSOtpAuthenticationRepositoryException extends ServerException {
  /// Constructor for the SMSOtpAuthenticationRepositoryException class
  SMSOtpAuthenticationRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(
          errorMessage:
              'SMSOtpAuthenticationRepositoryException -> $errorMessage',
        );
}

/// SMS OTP authentication
class SMSOtpAuthenticationRepository {
  /// Constructor
  const SMSOtpAuthenticationRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Send OTP to user
  Future<void> sendOtpToUser(
    String phoneNumber,
  ) async {
    try {
      await supabaseClient.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (err) {
      throw SMSOtpAuthenticationRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Retrieve token and refresh token
  Future<Map<String, String>> verifyAndLoginUserOtp(
    String phoneNumber,
    String token,
  ) async {
    try {
      final authResponse = await supabaseClient.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: phoneNumber,
      );
      final session = authResponse.session!;
      return {
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken!,
      };
    } catch (err) {
      throw SMSOtpAuthenticationRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Refresh access and refresh token
  Future<Map<String, String>> refreshAccessToken(
    String refreshToken,
  ) async {
    try {
      final authResponse = await supabaseClient.auth.setSession(refreshToken);
      final session = authResponse.session!;
      return {
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken!,
      };
    } catch (err) {
      throw SMSOtpAuthenticationRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
