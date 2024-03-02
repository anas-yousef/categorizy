import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/authentication_repository.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  return handler

      /// The AuthenticationRepository will be used to authenticate every
      /// inbound request, whether the access token supplied is valid
      .use(provider<AuthenticationRepository>((_) => authenticationRepository));
}
