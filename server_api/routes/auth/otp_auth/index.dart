import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/sms_otp_authentication_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    // Create category
    return _createOrRefreshSession(context);
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _createOrRefreshSession(RequestContext context) async {
  final smsOtpAuthenticationRepository =
      context.read<SMSOtpAuthenticationRepository>();
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final otpToken = body['otp_token'] as String?;
    final refreshToken = body['refresh_token'] as String?;
    final phoneNumber = body['phone_number'] as String?;
    final Map<String, String> tokens;
    if (otpToken != null && phoneNumber != null) {
      tokens = await smsOtpAuthenticationRepository.verifyAndLoginUserOtp(
        phoneNumber,
        otpToken,
      );
    }
    else if (refreshToken != null)
    {
      tokens = await smsOtpAuthenticationRepository.refreshAccessToken(
        refreshToken,
      );
    }
    else
    {
      throw Exception('Not enough arguments to create/refresh session');
    }
    return Response.json(body: {'auth': tokens});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Creating or refreshing session',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}
