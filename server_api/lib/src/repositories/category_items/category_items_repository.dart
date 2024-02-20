import 'package:server_api/server_exception.dart';
import 'package:supabase/supabase.dart';

/// An exception class for the category itemS repository
class CategoryItemsRepositoryException extends ServerException {
  /// Constructor for the SingleCategoryItemRepositoryException class
  CategoryItemsRepositoryException({
    required String errorMessage,
    super.errorBody,
  }) : super(errorMessage: 'CategoryItemsRepositoryException -> $errorMessage');
}

/// For interacting with the Category ItemS object in the database
class CategoryItemsRepository {
  /// Constructor
  const CategoryItemsRepository({required this.supabaseClient});

  /// The supabase client
  final SupabaseClient supabaseClient;

  /// Retrieve category items of a specific category ID
  Future<List<Map<String, dynamic>>> fetchCategoryItemsOfCategory(
    int categoryId,
  ) async {
    try {
      return await supabaseClient
          .from('category_items')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);
    } catch (err) {
      throw CategoryItemsRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Inserts a new category item
  Future<Map<String, dynamic>> insertNewCategoryItem(
    String categoryItemName,
    int categoryId,
    String userId,
  ) async {
    try {
      return await supabaseClient
          .from('category_items')
          .upsert(
            {
              'created_at': DateTime.now().toString(),
              'user_id': userId,
              'category_item_name': categoryItemName,
              'category_id': categoryId,
            },
            onConflict: 'category_item_name',
            ignoreDuplicates: true,
          )
          .select()
          .single();
    } catch (err) {
      throw CategoryItemsRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }

  /// Deletes a list of category items
  /// TODO Will need to check how to do a bulk delete
  Future<void> deleteCategoryItems(
    List<int> categoryItemIds,
    int categoryId,
  ) async {
    try {
      await supabaseClient
          .from('category_items')
          .delete()
          .eq('category_id', categoryId)
          .inFilter('id', categoryItemIds)
          .limit(categoryItemIds.length)
          .order('created_at');
    } catch (err) {
      throw CategoryItemsRepositoryException(
        errorMessage: err.toString(),
      );
    }
  }
}
