import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server_api/src/repositories/categories_repository.dart';

// Entrypoint to all categories [for fetching, updating, deleting]
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _get(context);
  }
  if (context.request.method == HttpMethod.delete) {
    // Delete category
    return _delete(context);
  }
  if (context.request.method == HttpMethod.post) {
    // Create category
    return _create(context);
  } else {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final categoriesRepository = context.read<CategoriesRepository>();
  try {
    final categories = await categoriesRepository.fetchCategories();
    return Response.json(body: {'categories': categories});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Fetching categories',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _delete(RequestContext context) async {
  final categoriesRepository = context.read<CategoriesRepository>();
  final body = await context.request.json() as Map<String, dynamic>;
  print(body['categories']);
  final categoryIDsToDelete = body['categories'] as List<String>;
  try {
    await categoriesRepository.deleteCategories(categoryIDsToDelete);
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

Future<Response> _create(RequestContext context) async {
  final categoriesRepository = context.read<CategoriesRepository>();
  final body = await context.request.json() as Map<String, dynamic>;
  final categoryName = body['category_name'] as String;
  final userId = body['user_id'] as String;
  try {
    final newCategory =
        await categoriesRepository.insertNewCategory(categoryName, userId);
    return Response.json(body: {'category': newCategory});
  } catch (err) {
    return Response.json(
      body: {
        'error': err.toString(),
        'error_source': 'Creating category',
      },
      statusCode: HttpStatus.internalServerError,
    );
  }
}