import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/category_item.dart';

class SupabaseApiUtility {
  static final SupabaseApiUtility _singleton = SupabaseApiUtility._internal();
  late final SupabaseClient supabaseClient;

  factory SupabaseApiUtility() {
    return _singleton;
  }
  SupabaseApiUtility._internal();

  Future<Supabase> getSupabaseInitializer() {
    return Supabase.initialize(
      url: 'https://cllxiizwxphmrtyrcoqj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNsbHhpaXp3eHBobXJ0eXJjb3FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDA4Mjc5NTEsImV4cCI6MjAxNjQwMzk1MX0.pxq0x9pwpFFOguBUJ_D95Gk0cKoDe4-lIPsOFu0zw0I',
      authFlowType: AuthFlowType.pkce,
    );
  }

  // This should be called after the initializer getSupabaseInitializer()
  void setSupabaseClient() {
    supabaseClient = Supabase.instance.client;
  }

  /// The return type will be a list that holds the newly added Category. If the category already
  /// exists, then the list will be empty, if it is nwq, then the response will be a list
  /// of length 1, holding the newly added Category
  Future<Category?> insertNewCategory({required String categoryName}) async {
    var currentUser = supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw Exception('An authenticated user is needed');
    }
    var response = await supabaseClient.from('categories').upsert({
      'created_at': DateTime.now().toString(),
      'user_id': currentUser.id,
      'category_name': categoryName
    }, onConflict: 'category_name', ignoreDuplicates: true).select()
        as List<dynamic>;
    return (response.isEmpty ? null : Category.fromApi(response[0]));
  }

  /// The return type will be a list that holds the newly added Category Item. If the category Item already
  /// exists, then the list will be empty, if it is nwq, then the response will be a list
  /// of length 1, holding the newly added Category Item
  Future<CategoryItem?> insertNewCategoryItem(
      {required String categoryItemName, required int categoryId}) async {
    var currentUser = supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw Exception('An authenticated user is needed');
    }
    var response = await supabaseClient.from('category_items').upsert({
      'created_at': DateTime.now().toString(),
      'user_id': currentUser.id,
      'category_item_name': categoryItemName,
      'category_id': categoryId
    }, onConflict: 'category_item_name', ignoreDuplicates: true).select()
        as List<dynamic>;
    return (response.isEmpty ? null : CategoryItem.fromApi(response[0]));
  }

  Future<void> deleteCategory({required int categoryId}) async {
    await supabaseClient.from('categories').delete().match({'id': categoryId});
  }

  // TODO Do we need the category ID to delete a category item?
  Future<void> deleteCategoryItem({required int categoryItemId}) async {
    await supabaseClient
        .from('category_items')
        .delete()
        .match({'id': categoryItemId});
  }

  Future<List<Category>> fetchCategories() async {
    final response = await supabaseClient.from('categories').select('''
      id,category_name,category_items(id,category_item_name,checked)
      ''').order('created_at', ascending: false) as List<dynamic>;
    final categories = response
        .map((dynamic categoryObject) => Category.fromApi(categoryObject))
        .toList();
    return categories;
  }

  Future<List<CategoryItem>> fetchCategoryItems(
      {required int categoryId}) async {
    final response = await supabaseClient.from('category_items').select('''
      id,category_item_name,checked,category_id
      ''').eq('category_id', categoryId).order('created_at', ascending: false)
        as List<dynamic>;
    final categoryItems = response
        .map((dynamic categoryItemObject) =>
            CategoryItem.fromApi(categoryItemObject))
        .toList();
    return categoryItems;
  }
}
