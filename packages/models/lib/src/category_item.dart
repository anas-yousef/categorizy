import 'package:equatable/equatable.dart';

class CategoryItem extends Equatable {
  final int id;
  final int categoryId;
  final String name;
  final bool checked;
  const CategoryItem({
    required this.name,
    this.checked = false,
    required this.id,
    required this.categoryId,
  });

  CategoryItem copy({String? name, bool? checked, int? id, int? categoryId}) =>
      CategoryItem(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        checked: checked ?? this.checked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'checked': checked,
      };

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      checked: json['checked'],
    );
  }

  @override
  List<Object?> get props => [id, categoryId, name, checked];
}
