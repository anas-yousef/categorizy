import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/category_items/category_items_repository.dart';

import '../../../../../main.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(
        provider<CategoryItemsRepository>(
          (_) => categoryItemsRepository,
        ),
      );
}
