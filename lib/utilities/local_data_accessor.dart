import 'dart:convert';

import '../models/category.dart';
import '../models/category_item.dart';
import 'user_shared_preferences.dart';

// This class is a singleton class, and it acts as a mediator between the application and the local data storage
// In our case, we use the Shared Preference local data storage
class LocalDataAccessor {
  static final LocalDataAccessor _instance = LocalDataAccessor._internal();
  late final UserSharedPreferences userSharedPreferences;
  factory LocalDataAccessor() {
    return _instance;
  }
  LocalDataAccessor._internal() {
    userSharedPreferences = UserSharedPreferences();
  }

  Future<void> init() async {
    await userSharedPreferences.init();
  }

  Future<bool> addCategory(String categoryName) async {
    return await userSharedPreferences.addCategory(categoryName);
  }

  Future<bool> addCategoryItem(
      String categoryName, CategoryItem categoryItem) async {
    // Get the encoded category items
    List<String> encodedCategoryItems =
        userSharedPreferences.getEncodedCategoryItems(categoryName);
    // Add the encoded category item
    encodedCategoryItems.add(jsonEncode(categoryItem));
    return await userSharedPreferences.setEncodedCategoryItems(
        categoryName, encodedCategoryItems);
  }

  Future<List<bool>> deleteCategory(String categoryName) async {
    return await userSharedPreferences.removeCategory(categoryName);
  }

  Future<bool> deleteCategoryItem(
      String categoryName, CategoryItem categoryItem) async {
    // Retrieve the category items
    var categoryItems = getCategoryItems(categoryName);
    // Remove the category item that matches the supplied item
    categoryItems.removeWhere((element) => element.name == categoryItem.name);
    // Encode the new category items so they can be saved
    List<String> encodedCategoryItems =
        categoryItems.map((categoryItem) => jsonEncode(categoryItem)).toList();
    return await userSharedPreferences.setEncodedCategoryItems(
        categoryName, encodedCategoryItems);
  }

  List<String> getCategoryNames() {
    return userSharedPreferences.getCategoryNames();
  }

  List<Category> getCategories() {
    // We first retrieve the names of the categories from the DB
    List<String> categoryNames = getCategoryNames();
    List<Category> categories = [];
    for (var categoryName in categoryNames) {
      // For every category name, we retrieve the category items related to it
      List<CategoryItem> categoryItems = getCategoryItems(categoryName);
      Category category =
          Category(categoryItems: categoryItems, name: categoryName, id:99);
      categories.add(category);
    }
    return categories;
  }

  List<CategoryItem> getCategoryItems(String categoryName) {
    List<String> encodedCategoryItems =
        userSharedPreferences.getEncodedCategoryItems(categoryName);
    return encodedCategoryItems.map(
      (String encodedCategoryItem) {
        Map<String, dynamic> categoryItemJson = jsonDecode(encodedCategoryItem);
        try {
          return CategoryItem.fromJson(categoryItemJson);
        } on Exception catch (e) {
          print('Exception details:\n $e');
          throw Exception(e);
        } catch (e, s) {
          print('Exception details:\n $e');
          print('Stack trace:\n $s');
          throw Exception(e);
        }
      },
    ).toList();
  }

  Future<bool> editCategoryItem(
      String categoryName, CategoryItem categoryItem) async {
    // Retrieve the category items
    var categoryItems = getCategoryItems(categoryName);
    var itemIndex = categoryItems
        .indexWhere((element) => element.name == categoryItem.name);
    if (itemIndex == -1) {
      print('CategoryItem not found :(');
      throw Exception('CategoryItem not found when trying to edit');
    }
    categoryItems[itemIndex] = categoryItem;
    // Encode the new category items so they can be saved
    List<String> encodedCategoryItems =
        categoryItems.map((categoryItem) => jsonEncode(categoryItem)).toList();
    return await userSharedPreferences.setEncodedCategoryItems(
        categoryName, encodedCategoryItems);
  }
}
