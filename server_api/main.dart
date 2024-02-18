import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:server_api/src/repositories/categories_repository.dart';
import 'package:server_api/src/repositories/category_repository.dart';
import 'package:supabase/supabase.dart';

late CategoryRepository categoryRepository;
late CategoriesRepository categoriesRepository;


Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final supabaseClient = SupabaseClient(
    env['SUPB_URL']!,
    // ignore: lines_longer_than_80_chars
    env['SUPB_SERVICE_ROLE']!, // This is only used in the server, not on the client side
  );
  categoryRepository = CategoryRepository(supabaseClient: supabaseClient);
  categoriesRepository = CategoriesRepository(supabaseClient: supabaseClient);
  return serve(handler, ip, port);
}
