import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the categories repository
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
      return await supabaseClient
          .from('categories')
          .select('*,category_items(*)')
          .order('created_at', ascending: false);
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
  /// TODO Will need to check how to do a bulk delete
  Future<void> deleteCategories(List<int> categoryIds) async {
    try {
      await supabaseClient
          .from('categories')
          .delete()
          .inFilter('id', categoryIds)
          .limit(categoryIds.length)
          .order('created_at');
    } catch (err) {
      throw CategoriesRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
