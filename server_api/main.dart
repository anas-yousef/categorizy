import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:server_api/src/repositories/categories/categories_repository.dart';
import 'package:server_api/src/repositories/categories/single_category_repository.dart';
import 'package:server_api/src/repositories/category_items/single_category_item_repository.dart';
import 'package:server_api/src/repositories/category_items/category_items_repository.dart';
import 'package:supabase/supabase.dart';

// Category/Categories repositories
late SingleCategoryRepository singleCategoryRepository;
late CategoriesRepository categoriesRepository;

// Category Item/Category Items repositories
late SingleCategoryItemRepository singleCategoryItemRepository;
late CategoryItemsRepository categoryItemsRepository;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final supabaseClient = SupabaseClient(
    env['SUPB_URL']!,
    // ignore: lines_longer_than_80_chars
    env['SUPB_SERVICE_ROLE']!, // This is only used in the server, not on the client side
  );
  singleCategoryRepository =
      SingleCategoryRepository(supabaseClient: supabaseClient);
  categoriesRepository = CategoriesRepository(supabaseClient: supabaseClient);

  singleCategoryItemRepository =
      SingleCategoryItemRepository(supabaseClient: supabaseClient);
  categoryItemsRepository =
      CategoryItemsRepository(supabaseClient: supabaseClient);

  return serve(handler, ip, port);
}
