import 'package:flutter/material.dart';

import '../utilities/app_logger.dart';
import '../models/category.dart';
import '../models/category_item.dart';
import '/utilities/supabase_api_utility.dart';

class SupabaseProvider extends ChangeNotifier {
  List<Category> categories = [];

  // Get the index of the Category that has the id $categoryId
  int getCategoryIndex({required int categoryId}) {
    var categoryIndexId =
        categories.indexWhere((element) => element.id == categoryId);
    if (categoryIndexId == -1) {
      throw Exception('There is no category with the ID $categoryIndexId');
    }
    return categoryIndexId;
  }

  // Get the index of the Category Item that has the id $categoryItemId
  int getCategoryItemIndex(
      {required Category category, required int categoryItemId}) {
    var categoryItemIndexId = category.categoryItems
        .indexWhere((element) => element.id == categoryItemId);
    if (categoryItemIndexId == -1) {
      throw Exception(
          'There is no category item with the ID $categoryItemIndexId');
    }
    return categoryItemIndexId;
  }

  Future<void> createCategory(
      {required String categoryName,
      required ScaffoldMessengerState scaffoldMessenger}) async {
    try {
      Category? newlyAddedCategory =
          await Future.delayed(const Duration(milliseconds: 500), () async {
        return await SupabaseApiUtility()
            .insertNewCategory(categoryName: categoryName);
      });
      if (newlyAddedCategory == null) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('There is already a category with the same name')));
      } else {
        categories.insert(0, newlyAddedCategory);
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Category "$categoryName" created successfully')));
      }
    } on Exception catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }

  // Will be called only if the the build context object is mounted
  Future<void> createCategoryItem(
      {required String categoryItemName,
      required int categoryId,
      required ScaffoldMessengerState scaffoldMessenger}) async {
    try {
      CategoryItem? newlyAddedCategoryItem =
          await Future.delayed(const Duration(milliseconds: 500), () async {
        return await SupabaseApiUtility().insertNewCategoryItem(
            categoryItemName: categoryItemName, categoryId: categoryId);
      });
      // TODO Throw an exception, and let the parent function handle it
      if (newlyAddedCategoryItem == null) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                Text('There is already a category item with the same name')));
      } else {
        var categoryIndexId = getCategoryIndex(categoryId: categoryId);
        categories[categoryIndexId] =
            categories[categoryIndexId].copy(categoryItems: [
          newlyAddedCategoryItem,
          ...categories[categoryIndexId].categoryItems,
        ]);
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
                'Category Item "$categoryItemName" created successfully')));
      }
    } on Exception catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }

  Future<void> getCategories() async {
    try {
      categories = await SupabaseApiUtility().fetchCategories();
      AppLogger().logger.i('Successfully got all categories');
    } catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }

  Future<void> getCategoryItems({required int categoryId}) async {
    try {
      var categoryItems =
          await SupabaseApiUtility().fetchCategoryItems(categoryId: categoryId);
      var categoryIndexId = getCategoryIndex(categoryId: categoryId);
      categories[categoryIndexId] =
          categories[categoryIndexId].copy(categoryItems: categoryItems);
      AppLogger()
          .logger
          .i('Successfully got category items for category ID $categoryId');
    } catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }

  Future<void> updateCategoryItem(
      {required int categoryId,
      required int categoryItemId,
      required bool newCheckedValue}) async {
    try {
      CategoryItem? newCategoryItem =
          await Future.delayed(const Duration(milliseconds: 500), () async {
        return await SupabaseApiUtility().updateCategoryItem(
            categoryItemId: categoryItemId, newCheckedValue: newCheckedValue);
      });
      if (newCategoryItem == null) {
        throw Exception('How come the category item is null');
      }
      var categoryIndexId = getCategoryIndex(categoryId: categoryId);
      var categoryItemIndexId = getCategoryItemIndex(
          category: categories[categoryIndexId],
          categoryItemId: categoryItemId);
      categories[categoryIndexId].categoryItems[categoryItemIndexId] =
          newCategoryItem;
    } catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }

  Future<void> deleteCategory(
      {required int categoryId,
      required String categoryName,
      required ScaffoldMessengerState scaffoldMessenger}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500), () async {
        await SupabaseApiUtility().deleteCategory(categoryId: categoryId);
      });
      var categoryIndexId = getCategoryIndex(categoryId: categoryId);
      categories.removeAt(categoryIndexId);
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Category $categoryName deleted successfully')));
    } catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }

  Future<void> deleteCategoryItem(
      {required int categoryItemId,
      required int categoryId,
      required String categoryItemName,
      required ScaffoldMessengerState scaffoldMessenger}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500), () async {
        await SupabaseApiUtility()
            .deleteCategoryItem(categoryItemId: categoryItemId);
      });
      var categoryIndexId = getCategoryIndex(categoryId: categoryId);
      categories[categoryIndexId]
          .categoryItems
          .removeWhere((element) => element.id == categoryItemId);
      scaffoldMessenger.showSnackBar(SnackBar(
          content:
              Text('Category item $categoryItemName deleted successfully')));
    } catch (error) {
      AppLogger().logger.e(error.toString());
    }
    notifyListeners();
  }
}
