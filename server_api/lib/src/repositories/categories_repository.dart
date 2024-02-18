import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the category repository
class CategoriesRepositoryException extends ServerException {
  /// Constructor for the CategoriesRepositoryException class
  CategoriesRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(errorMessage: 'CategoriesRepositoryException -> $errorMessage');
}

/// For interacting with the Category object in the database
class CategoriesRepository {
  /// Constructor
  const CategoriesRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Retrieve all categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      return await supabaseClient.from('categories').select('''
      id,category_name,category_items(id,category_item_name,checked,category_id)
      ''').order('created_at', ascending: false);
    } catch (err) {
      throw CategoriesRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Inserts a new category
  Future<Map<String, dynamic>> insertNewCategory(
    String categoryName,
    String userId,
  ) async {
    try {
      return await supabaseClient
          .from('categories')
          .upsert(
            {
              'created_at': DateTime.now().toString(),
              'user_id': userId,
              'category_name': categoryName,
            },
            onConflict: 'category_name',
            ignoreDuplicates: true,
          )
          .select()
          .single();
    } catch (err) {
      throw CategoriesRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Deletes a list of categories
  Future<void> deleteCategories(List<String> categoryIds) async {
    try {
      await supabaseClient
          .from('categories')
          .delete()
          .inFilter('id', categoryIds)
          .limit(categoryIds.length);
    } catch (err) {
      throw CategoriesRepositoryException(
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
      throw CategoriesRepositoryException(
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
          .match({'id': categoryId}).single();
    } catch (err) {
      throw CategoriesRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
