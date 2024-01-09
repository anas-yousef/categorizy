import 'package:categorizy/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/confirm_delete_dialog_builder.dart';
import '../models/category_item.dart';

class CategoryItemWidget extends StatefulWidget {
  final List<CategoryItem> categoryItems;
  final int categoryItemIndex;
  final Future<void> Function() refreshCategoryItems;
  const CategoryItemWidget({
    super.key,
    required this.categoryItems,
    required this.categoryItemIndex,
    required this.refreshCategoryItems,
  });

  @override
  State<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
  late bool _isDeleting;
  late bool _isUpdating;
  @override
  void initState() {
    _isDeleting = false;
    _isUpdating = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoryItem = widget.categoryItems[widget.categoryItemIndex];
    return SizedBox(
      height: 50,
      child: Consumer<SupabaseProvider>(
          builder: (context, supabaseProvider, child) {
        return _isDeleting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Dismissible(
                key: Key('${categoryItem.id}'),
                onDismissed: (direction) async {
                  ScaffoldMessengerState scaffoldMessenger =
                      ScaffoldMessenger.of(context);
                  setState(() {
                    _isDeleting = true;
                  });
                  // Remove the item from the data source.
                  await supabaseProvider.deleteCategoryItem(
                    categoryItemId: categoryItem.id,
                    categoryId: categoryItem.categoryId,
                    categoryItemName: categoryItem.name,
                    scaffoldMessenger: scaffoldMessenger,
                  );
                  setState(() {
                    _isDeleting = false;
                  });
                  widget.refreshCategoryItems();
                },
                confirmDismiss: (direction) async {
                  return await confirmDismissDialogBuilder(context: context);
                },
                background: Container(color: Colors.red),
                child: ListTile(
                  trailing: _isUpdating
                      ? const CircularProgressIndicator()
                      : Checkbox(
                          onChanged: (bool? value) async {
                            if (value != null) {
                              setState(() {
                                _isUpdating = true;
                              });
                              await supabaseProvider.updateCategoryItem(
                                  categoryItemId: categoryItem.id,
                                  newCheckedValue: value,
                                  categoryId: categoryItem.categoryId);
                              setState(() {
                                _isUpdating = false;
                              });
                            }
                          },
                          value: categoryItem.checked,
                        ),
                  title: Text(
                    categoryItem.name,
                  ),
                ),
              );
      }),
    );
  }
}
