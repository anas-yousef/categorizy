import 'category_item.dart';

class Category {
  final int id;
  final String name;
  final List<CategoryItem> categoryItems;
  Category({required this.categoryItems, required this.name, required this.id});

  Category copy({
    String? name,
    List<CategoryItem>? categoryItems,
    int? id,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryItems: categoryItems ?? this.categoryItems,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categories': categoryItems,
      };

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['category_name'],
        categoryItems = json['category_items'];

  static Category fromApi(Map<String, dynamic> apiObject) {
    final List<CategoryItem> categoryItems = [];
    List<dynamic> categoryItemsFromApi = apiObject['category_items'] ?? [];
    for (final itemFromApi in categoryItemsFromApi) {
      categoryItems.add(CategoryItem.fromApi(itemFromApi));
    }
    return Category(
        id: apiObject['id'] as int,
        name: apiObject['category_name'] as String,
        categoryItems: categoryItems);
  }
}
