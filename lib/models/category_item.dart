class CategoryItem {
  final int id;
  final String name;
  final bool checked;
  const CategoryItem(
      {required this.name, this.checked = false, required this.id});

  CategoryItem copy({
    String? name,
    bool? checked,
    int? id,
  }) =>
      CategoryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        checked: checked ?? this.checked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'checked': checked,
      };

  CategoryItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        checked = json['checked'];

  CategoryItem.fromApi(Map<String, dynamic> apiObject)
      : id = apiObject['id'] as int,
        name = apiObject['category_item_name'] as String,
        checked = apiObject['checked'] as bool;
}
