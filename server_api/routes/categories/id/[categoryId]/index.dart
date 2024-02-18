import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/category_repository.dart';

Future<Response> onRequest(RequestContext context, String categoryId) async {
  if (context.request.method == HttpMethod.get) {
    return _get(context, categoryId);
  }
  if (context.request.method == HttpMethod.delete) {
    // Delete category
    return _delete(context, categoryId);
  }
  if (context.request.method == HttpMethod.put) {
    return _update(context, categoryId);
  }
  else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _delete(RequestContext context, String categoryId) async {
  final categoryRepository = context.read<CategoryRepository>();
  try {
    await categoryRepository.deleteCategory(categoryId);
    return Response.json();
  } catch (err) {
    // The error source should come from here
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Deleting category',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _get(RequestContext context, String categoryId) async {
  final categoryRepository = context.read<CategoryRepository>();
  try {
    final category = await categoryRepository.fetchCategory(categoryId);
    return Response.json(body: {'category': category});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Fetching category',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _update(RequestContext context, String categoryId) async {
  final categoryRepository = context.read<CategoryRepository>();
  final body = await context.request.json() as Map<String, dynamic>;
  final newCategoryName = body['category_name'] as String?;
  try {
    final newCategory = await categoryRepository.updateCategory(
      categoryId,
      newCategoryName: newCategoryName,
    );
    return Response.json(body: {'category': newCategory});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Updating category',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}
