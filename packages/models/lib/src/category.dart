import 'package:equatable/equatable.dart';

import 'category_item.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final List<CategoryItem> categoryItems;
  const Category({
    required this.categoryItems,
    required this.name,
    required this.id,
  });

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

  factory Category.fromJson(Map<String, dynamic> json) {
    var jsonCategoryItems = json['categoryItems'];
    return Category(
      id: json['id'],
      name: json['name'],
      categoryItems: (jsonCategoryItems is List)
          ? jsonCategoryItems
              .map<CategoryItem>(
                  (categoryItem) => CategoryItem.fromJson(categoryItem))
              .toList()
          : <CategoryItem>[],
    );
  }

  @override
  List<Object?> get props => [id, name, categoryItems];
}
