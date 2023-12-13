import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../utilities/local_data_accessor.dart';
import '../models/category_item.dart';

// A class that extends the Change Notifier API, to add and notify listeners
// We use it to notify the application when local data has been updated -> save/update/delete/read data locally
class CategoriesProvider extends ChangeNotifier {
  late final LocalDataAccessor _localDataAccessor;

  CategoriesProvider({
    required LocalDataAccessor localDataAccessor,
  }) {
    _localDataAccessor = localDataAccessor;
  }

  List<CategoryItem> getCategoryItems(String categoryName) {
    return _localDataAccessor.getCategoryItems(categoryName);
  }

  List<String> getCategoryNames() {
    return _localDataAccessor.getCategoryNames();
  }

  // Adding a new category
  void addCategory(String categoryName) async {
    var result = await _localDataAccessor.addCategory(categoryName);
    if (result == false) {
      print('Could not add category to local storage');
      throw Exception('Could not add category to local storage');
    }
    notifyListeners();
  }

  // Deleting a category
  void deleteCategory(String categoryName) async {
    var boolResults = await _localDataAccessor.deleteCategory(categoryName);
    for (var i = 0; i < boolResults.length; i++) {
      if (boolResults[i] == false) {
        print('Boolean result in $i position is false :(');
        throw Exception('Boolean result in $i position is false :(');
      }
    }
    notifyListeners();
  }

  // Saving a new category item
  void addCategoryItem(String categoryName, CategoryItem categoryItem) async {
    var result =
        await _localDataAccessor.addCategoryItem(categoryName, categoryItem);
    if (result == false) {
      print(
          'Could not add category item, with name ${categoryItem.name} for $categoryName to local storage');
      throw Exception(
          'Could not add category item, with name ${categoryItem.name} for $categoryName to local storage');
    }
    notifyListeners();
  }

  // Editing a category item
  void editCategoryItem(String categoryName, CategoryItem categoryItem) async {
    var result =
        await _localDataAccessor.editCategoryItem(categoryName, categoryItem);
    if (result == false) {
      print(
          'Could not edit category item, with name ${categoryItem.name} for $categoryName to local storage');
      throw Exception(
          'Could not edit category item, with name ${categoryItem.name} for $categoryName to local storage');
    }
    notifyListeners();
  }

  // Deleting a category item
  void deleteCategoryItem(
      String categoryName, CategoryItem categoryItem) async {
    var result =
        await _localDataAccessor.deleteCategoryItem(categoryName, categoryItem);
    if (result == false) {
      print(
          'Could not delete category item, with name ${categoryItem.name} for $categoryName to local storage');
      throw Exception(
          'Could not delete category item, with name ${categoryItem.name} for $categoryName to local storage');
    }
    notifyListeners();
  }
}
