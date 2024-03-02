import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:server_api/src/repositories/authentication_repository.dart';
import 'package:supabase/supabase.dart';

Handler middleware(Handler handler) {
  return handler.use(
    /// Every request under the /api route will have to go through a verification
    /// step, to check if the supplied bearer token is valid
    bearerAuthentication<User>(
      authenticator: (context, token) async {
        final authenticator = context.read<AuthenticationRepository>();
        return authenticator.verifyToken(token);
      },
    ),
  );
}
