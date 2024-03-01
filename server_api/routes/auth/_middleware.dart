import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/sms_otp_authentication_repository.dart';

import '../../main.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(
        provider<SMSOtpAuthenticationRepository>(
          (_) => smsOtpAuthenticationRepository,
        ),
      );
}
