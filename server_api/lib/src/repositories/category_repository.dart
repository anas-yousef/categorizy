import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the category repository
class CategoryRepositoryException extends ServerException {
  /// Constructor for the CategoryRepositoryException class
  CategoryRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(errorMessage: 'CategoryRepositoryException -> $errorMessage');
}

/// For interacting with the Category object in the database
class CategoryRepository {
  /// Constructor
  const CategoryRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Fetches a specific category
  Future<Map<String, dynamic>> fetchCategory(String categoryId) async {
    try {
      return await supabaseClient.from('categories').select('''
      id,category_name,category_items(id,category_item_name,checked,category_id)
      ''').eq('id', categoryId).single();
    } catch (err) {
      throw CategoryRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Updates a category
  Future<Map<String, dynamic>> updateCategory(
    String categoryId, {
    String? newCategoryName,
  }) async {
    final dataToUpdate = {
      if (newCategoryName != null) 'category_name': newCategoryName,
    };
    try {
      return await supabaseClient
          .from('categories')
          .update(dataToUpdate)
          .match({'id': categoryId}).select('''
      id,category_name,category_items(id,category_item_name,checked,category_id)
      ''').single();
    } catch (err) {
      throw CategoryRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Deletes a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await supabaseClient
          .from('categories')
          .delete()
          // .match works like several .eq
          .match(
        {
          'id': categoryId,
        },

        /// We use single() to ensure that the supplied category ID was indeed
        /// found and deleted
      ).single();
    } catch (err) {
      throw CategoryRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
