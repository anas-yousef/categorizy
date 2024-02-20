import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the category item repository
class SingleCategoryItemRepositoryException extends ServerException {
  /// Constructor for the SingleCategoryItemRepositoryException class
  SingleCategoryItemRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(
          errorMessage:
              'SingleCategoryItemRepositoryException -> $errorMessage',
        );
}

/// For interacting with the Category Item object in the database
/// of a specific category
class SingleCategoryItemRepository {
  /// Constructor
  const SingleCategoryItemRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Retrieve one category item
  Future<Map<String, dynamic>> fetchCategoryItem(
    int categoryItemId,
    int categoryId,
  ) async {
    try {
      return await supabaseClient
          .from('category_items')
          .select()
          .match({
            'id': categoryItemId,
            'category_id': categoryId,
          })
          .order('created_at', ascending: false)
          .single();
    } catch (err) {
      throw SingleCategoryItemRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Deletes a category item
  Future<void> deleteCategoryItem(
    int categoryItemId,
    int categoryId,
  ) async {
    try {
      await supabaseClient
          .from('category_items')
          .delete()
          .match(
            {
              'id': categoryItemId,
              'category_id': categoryId,
            },
          )
          .select()
          .single();
    } catch (err) {
      throw SingleCategoryItemRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Updates a category item
  Future<Map<String, dynamic>> updateCategoryItem(
    int categoryItemId,
    int categoryId, {
    bool? newCheckedValue,
    String? newCategoryItemName,
  }) async {
    final dataToUpdate = {
      if (newCheckedValue != null) 'checked': newCheckedValue,
      if (newCategoryItemName != null)
        'category_item_name': newCategoryItemName,
    };
    try {
      return await supabaseClient
          .from('category_items')
          .update(dataToUpdate)
          .match({
            'id': categoryItemId,
            'category_id': categoryId,
          })
          .select()
          .single();
    } catch (err) {
      throw SingleCategoryItemRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
