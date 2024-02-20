import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/categories/single_category_repository.dart';

import '../../../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<SingleCategoryRepository>((_) => singleCategoryRepository));
}
