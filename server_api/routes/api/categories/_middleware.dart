import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/categories/categories_repository.dart';

import '../../../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<CategoriesRepository>((_) => categoriesRepository));
}
