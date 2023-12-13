import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '/utilities/supabase_api_utility.dart';
import '../utilities/custom_exception.dart';

class SupabaseProvider extends ChangeNotifier {
  List<Category> categories = [];

  // Will be called only if the the build context object is mounted
  Future<void> createCategory(
      {required String categoryName, required BuildContext context}) async {
    try {
      var res = await SupabaseApiUtility()
          .insertNewCategory(categoryName: categoryName);
      if (res.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('There is already a category with the same name'),
        ));
      } else {
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

  Future<void> getCategories() async {
    categories = await SupabaseApiUtility().fetchCategories();
    notifyListeners();
  }

  Future<void> getCategoryItems({required int categoryId}) async {
    var categoryItems =
        await SupabaseApiUtility().fetchCategoryItems(categoryId: categoryId);
    var categoryIndexId =
        categories.indexWhere((element) => element.id == categoryId);
    if (categoryIndexId == -1) {
      throw Exception('There is no category with the ID $categoryIndexId');
    }
    categories[categoryIndexId] =
        categories[categoryIndexId].copy(categoryItems: categoryItems);
    notifyListeners();
  }
}
