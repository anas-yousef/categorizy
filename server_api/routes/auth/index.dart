import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/sms_otp_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    // Send OTP
    return _sendOtp(context);
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _sendOtp(RequestContext context) async {
  final smsOtpRepository = context.read<SMSOtpRepository>();
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final phoneNumber = body['phone_number'] as String?;
    if (phoneNumber == null) {
      throw Exception('Phone number is missing');
    }
    await smsOtpRepository.sendOtpToUser(
      phoneNumber,
    );
    return Response.json();
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
