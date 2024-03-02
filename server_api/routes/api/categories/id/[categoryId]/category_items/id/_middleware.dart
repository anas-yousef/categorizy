import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/category_items/single_category_item_repository.dart';

import '../../../../../../../main.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(
        provider<SingleCategoryItemRepository>(
          (_) => singleCategoryItemRepository,
        ),
      );
}
