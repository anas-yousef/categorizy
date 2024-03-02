import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart' as supabase;

/// For access token verification https://github.com/supabase/supabase/issues/491#issuecomment-871863896
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    // Get user
    return _getUserUsingAccessToken(context);
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getUserUsingAccessToken(RequestContext context) async {
  try {
    final user = context.read<supabase.User>();
    return Response.json(
      body: {
        'user': {'created_at': user.createdAt},
      },
    );
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Getting user',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}
