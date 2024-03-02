import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/category_items/category_items_repository.dart';

// Entrypoint to all categories [for fetching, creating, deleting]
Future<Response> onRequest(RequestContext context, String categoryId) async {
  if (context.request.method == HttpMethod.get) {
    return _get(context, categoryId);
  } else if (context.request.method == HttpMethod.delete) {
    // Delete category
    return _delete(context, categoryId);
  } else if (context.request.method == HttpMethod.post) {
    // Create category
    return _create(context, categoryId);
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(
  RequestContext context,
  String categoryId,
) async {
  final categoryItemsRepository = context.read<CategoryItemsRepository>();
  try {
    final categoryItems = await categoryItemsRepository
        .fetchCategoryItemsOfCategory(int.parse(categoryId));
    return Response.json(body: {'category_items': categoryItems});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Fetching category items',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _delete(
  RequestContext context,
  String categoryId,
) async {
  final categoryItemsRepository = context.read<CategoryItemsRepository>();
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final categoryIDsToDelete =
        List<int>.from(body['category_items'] as List<dynamic>);
    await categoryItemsRepository.deleteCategoryItems(
      categoryIDsToDelete,
      int.parse(categoryId),
    );
    return Response.json();
  } catch (err) {
    // The error source should come from here
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Deleting category items',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _create(
  RequestContext context,
  String categoryId,
) async {
  final categoryItemsRepository = context.read<CategoryItemsRepository>();
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final categoryItemName = body['category_item_name'] as String;
    final userId = body['user_id'] as String;
    final newCategoryItem = await categoryItemsRepository.insertNewCategoryItem(
      categoryItemName,
      int.parse(categoryId),
      userId,
    );
    return Response.json(body: {'category_item': newCategoryItem});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Creating category item',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}
