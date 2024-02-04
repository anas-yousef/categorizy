import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String categoryId) async {
  if (context.request.method == HttpMethod.get) {
    // Get category
  }
  if (context.request.method == HttpMethod.delete) {
    // Delete category
  }
  if (context.request.method == HttpMethod.patch) {
    // Update category
  }
  if (context.request.method == HttpMethod.put) {
    // Create category
  }
  return Response(body: 'Welcome to Dart Frog!');
}
