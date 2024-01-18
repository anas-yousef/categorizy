import 'package:categorizy/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/confirm_delete_dialog_builder.dart';
import '../helpers/text_dialog_builder.dart';
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
  late bool _isUpdatingChecked;
  late bool _isUpdatingName;
  late TextEditingController textFieldController;
  // late CategoryItem categoryItem;
  @override
  void initState() {
    _isDeleting = false;
    _isUpdatingChecked = false;
    _isUpdatingName = false;
    textFieldController = TextEditingController();
    // categoryItem = widget.categoryItems[widget.categoryItemIndex];
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryItem = widget.categoryItems[widget.categoryItemIndex];
    // textFieldController.text = categoryItem.name;
    return SizedBox(
      height: 50,
      child: Consumer<SupabaseProvider>(
          builder: (context, supabaseProvider, child) {
        return (_isDeleting || _isUpdatingName)
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
                  trailing: _isUpdatingChecked
                      ? const CircularProgressIndicator()
                      : Checkbox(
                          onChanged: (bool? value) async {
                            ScaffoldMessengerState scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            if (value != null) {
                              setState(() {
                                _isUpdatingChecked = true;
                              });
                              await supabaseProvider.updateCategoryItem(
                                  categoryItemId: categoryItem.id,
                                  newCheckedValue: value,
                                  categoryId: categoryItem.categoryId,
                                  scaffoldMessenger: scaffoldMessenger);
                              setState(() {
                                _isUpdatingChecked = false;
                              });
                            }
                          },
                          value: categoryItem.checked,
                        ),
                  onLongPress: () async {
                    ScaffoldMessengerState scaffoldMessenger =
                        ScaffoldMessenger.of(context);
                    final newCategoryItemName = await textDialogBuilder(
                      title: 'Update item:',
                      context: context,
                      textFieldController: textFieldController,
                      clearTextFieldOnCancel: false,
                      textFieldInitialValue: categoryItem.name,
                    );
                    if (newCategoryItemName != null &&
                        newCategoryItemName.isNotEmpty) {
                      setState(() {
                        _isUpdatingName = true;
                      });
                      await supabaseProvider.updateCategoryItem(
                          categoryItemId: categoryItem.id,
                          newCategoryItemName: newCategoryItemName,
                          categoryId: categoryItem.categoryId,
                          scaffoldMessenger: scaffoldMessenger);
                      setState(() {
                        _isUpdatingName = false;
                      });
                    }
                  },
                  title: Text(
                    categoryItem.name,
                  ),
                ),
              );
      }),
    );
  }
}
