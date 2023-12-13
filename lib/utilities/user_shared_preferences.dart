import 'package:shared_preferences/shared_preferences.dart';

/// This class is in charge of interacting with the Shared Preferences package, which is used to
/// read/delete/update/write data locally
class UserSharedPreferences {
  late SharedPreferences _userSharedPref;
  final _categoryNamesKey = 'categoryNamesKey';

  static final UserSharedPreferences _instance =
      UserSharedPreferences._internal();

  factory UserSharedPreferences() {
    return _instance;
  }
  UserSharedPreferences._internal();

  Future<void> init() async =>
      _userSharedPref = await SharedPreferences.getInstance();

  List<String> getCategoryNames() {
    return _userSharedPref.getStringList(_categoryNamesKey) ?? [];
  }

  Future<bool> addCategory(String categoryName) async {
    return await _addCategoryName(categoryName);
  }

  Future<bool> _addCategoryName(String categoryName) async {
    /// First retrieve all category names, then append the new category name,
    /// and save the new list
    List<String> categoryNames = getCategoryNames();
    categoryNames.add(categoryName);
    return await _userSharedPref.setStringList(
        _categoryNamesKey, categoryNames);
  }

  Future<bool> _removeCategoryName(String categoryName) async {
    /// First retrieve all category names, then delete the category name,
    /// and save the new list
    List<String> categoryNames = getCategoryNames();
    if (!categoryNames.remove(categoryName)) {
      // TODO Print to debug
      print('The specified category name was not found :(');
      return false;
    }
    return await _userSharedPref.setStringList(
        _categoryNamesKey, categoryNames);
  }

  Future<bool> _removeCategoryItems(String categoryName) async {
    return await _userSharedPref.remove(categoryName);
  }

  Future<List<bool>> removeCategory(String categoryName) async {
    List<Future<bool>> futures = [
      _removeCategoryName(categoryName),
      _removeCategoryItems(categoryName),
    ];
    return await Future.wait(futures, eagerError: true);
  }

  List<String> getEncodedCategoryItems(String categoryName) {
    return _userSharedPref.getStringList(categoryName) ?? [];
  }

  Future<bool> setEncodedCategoryItems(
      String categoryName, List<String> encodedCategoryItems) async {
    return await _userSharedPref.setStringList(
        categoryName, encodedCategoryItems);
  }
}
