import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the category repository
class SingleCategoryRepositoryException extends ServerException {
  /// Constructor for the SingleCategoryRepositoryException class
  SingleCategoryRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(
          errorMessage: 'SingleCategoryRepositoryException -> $errorMessage',
        );
}

/// For interacting with the Category object in the database
class SingleCategoryRepository {
  /// Constructor
  const SingleCategoryRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Fetches a specific category
  Future<Map<String, dynamic>> fetchCategory(int categoryId) async {
    try {
      return await supabaseClient
          .from('categories')
          .select('*,category_items(*)')
          .eq('id', categoryId)
          .single();
    } catch (err) {
      throw SingleCategoryRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Updates a category
  Future<Map<String, dynamic>> updateCategory(
    int categoryId, {
    String? newCategoryName,
  }) async {
    final dataToUpdate = {
      if (newCategoryName != null) 'category_name': newCategoryName,
    };
    try {
      return await supabaseClient
          .from('categories')
          .update(dataToUpdate)
          .match({'id': categoryId})
          .select('*,category_items(*)')
          .single();
    } catch (err) {
      throw SingleCategoryRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Deletes a category
  Future<void> deleteCategory(int categoryId) async {
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
          )
          .select()
          .single();
    } catch (err) {
      throw SingleCategoryRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
