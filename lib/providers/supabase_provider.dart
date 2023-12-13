import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/category_item.dart';
import '/utilities/supabase_api_utility.dart';
import '../utilities/custom_exception.dart';

class SupabaseProvider extends ChangeNotifier {
  List<Category> categories = [];

  // Get the index of the Category item that has the id $categoryId
  int _getCategoryIndex({required int categoryId}) {
    var categoryIndexId =
        categories.indexWhere((element) => element.id == categoryId);
    if (categoryIndexId == -1) {
      throw Exception('There is no category with the ID $categoryIndexId');
    }
    return categoryIndexId;
  }

  // Will be called only if the the build context object is mounted
  Future<void> createCategory(
      {required String categoryName, required BuildContext context}) async {
    try {
      var newlyAddedCategory = await SupabaseApiUtility()
          .insertNewCategory(categoryName: categoryName);
      if (newlyAddedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('There is already a category with the same name'),
        ));
      } else {
        categories.add(newlyAddedCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Category "$categoryName" created successfully')),
        );
      }
      notifyListeners();
    } on Exception catch (e) {
      throw CustomException(
          message: 'Error while creating a new category via Supabase API',
          mainException: e);
    }
  }

  // Will be called only if the the build context object is mounted
  Future<void> createCategoryItem(
      {required String categoryItemName,
      required int categoryId,
      required BuildContext context}) async {
    try {
      var newlyAddedCategoryItem = await SupabaseApiUtility()
          .insertNewCategoryItem(
              categoryItemName: categoryItemName, categoryId: categoryId);
      if (newlyAddedCategoryItem == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('There is already a category item with the same name'),
        ));
      } else {
        var categoryIndexId = _getCategoryIndex(categoryId: categoryId);
        categories[categoryIndexId] = categories[categoryIndexId].copy(
            categoryItems: [
              ...categories[categoryIndexId].categoryItems,
              newlyAddedCategoryItem
            ]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Category Item "$categoryItemName" created successfully')),
        );
      }
      notifyListeners();
    } on Exception catch (e) {
      throw CustomException(
          message: 'Error while creating a new category via Supabase API',
          mainException: e);
    }
  }

  Future<void> getCategories() async {
    categories = await SupabaseApiUtility().fetchCategories();
    notifyListeners();
  }

  Future<void> getCategoryItems({required int categoryId}) async {
    var categoryItems =
        await SupabaseApiUtility().fetchCategoryItems(categoryId: categoryId);
    var categoryIndexId = _getCategoryIndex(categoryId: categoryId);
    categories[categoryIndexId] =
        categories[categoryIndexId].copy(categoryItems: categoryItems);
    notifyListeners();
  }

  Future<void> deleteCategory(
      {required int categoryId,
      required String categoryName,
      required BuildContext context}) async {
    await SupabaseApiUtility().deleteCategory(categoryId: categoryId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category "$categoryName" deleted successfully')),
    );
    notifyListeners();
  }

  Future<void> deleteCategoryItem(
      {required int categoryItemId,
      required String categoryItemName,
      required BuildContext context}) async {
    await SupabaseApiUtility()
        .deleteCategoryItem(categoryItemId: categoryItemId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Category item "$categoryItemName" deleted successfully')),
    );
    notifyListeners();
  }
}
