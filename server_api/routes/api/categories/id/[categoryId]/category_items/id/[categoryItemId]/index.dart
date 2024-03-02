import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/category_items/single_category_item_repository.dart';

// Entrypoint to a specific category item [for fetching, updating, deleting]
Future<Response> onRequest(
  RequestContext context,
  String categoryId,
  String categoryItemId,
) async {
  if (context.request.method == HttpMethod.get) {
    return _get(
      context,
      categoryItemId,
      categoryId,
    );
  } else if (context.request.method == HttpMethod.delete) {
    return _delete(
      context,
      categoryItemId,
      categoryId,
    );
  } else if (context.request.method == HttpMethod.put) {
    return _update(
      context,
      categoryItemId,
      categoryId,
    );
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _delete(
  RequestContext context,
  String categoryItemId,
  String categoryId,
) async {
  final singleCategoryItemRepository =
      context.read<SingleCategoryItemRepository>();
  try {
    await singleCategoryItemRepository.deleteCategoryItem(
      int.parse(categoryItemId),
      int.parse(categoryId),
    );
    return Response.json();
  } catch (err) {
    // The error source should come from here
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Deleting category item',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _get(
  RequestContext context,
  String categoryItemId,
  String categoryId,
) async {
  final singleCategoryItemRepository =
      context.read<SingleCategoryItemRepository>();
  try {
    final categoryItem = await singleCategoryItemRepository.fetchCategoryItem(
      int.parse(categoryItemId),
      int.parse(categoryId),
    );
    return Response.json(body: {'category_item': categoryItem});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Fetching category item',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _update(
  RequestContext context,
  String categoryItemId,
  String categoryId,
) async {
  final singleCategoryItemRepository =
      context.read<SingleCategoryItemRepository>();
  final body = await context.request.json() as Map<String, dynamic>;
  final newCategoryItemName = body['category_item_name'] as String?;
  final newCheckedValue = body['checked'] as bool?;
  try {
    final newCategoryItem =
        await singleCategoryItemRepository.updateCategoryItem(
      int.parse(categoryItemId),
      int.parse(categoryId),
      newCategoryItemName: newCategoryItemName,
      newCheckedValue: newCheckedValue,
    );
    return Response.json(body: {'category_item': newCategoryItem});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Updating category item',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}
