import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/supabase_provider.dart';
import '../utilities/app_logger.dart';
import '/../providers/categories_provider.dart';
import '../models/category_item.dart';
import '../helpers/confirm_delete_dialog_builder.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  const CategoryScreen(
      {super.key, required this.categoryName, required this.categoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late bool _isLoading;
  late Future<void> _initCategoryItemsData;
  late TextEditingController textFieldController;
  @override
  void initState() {
    textFieldController = TextEditingController();
    super.initState();
  }

  Future<void> _refreshCategories() async {
    AppLogger().logger.i('Refreshing categories');
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textFieldController.dispose();
    super.dispose();
  }

  Future<String?> _newCategoryDialogBuilder(
      {required BuildContext context,
      required TextEditingController textFieldController}) async {
    return showDialog<String?>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enter new item:'),
        content: CupertinoTextField(
          autofocus: true,
          controller: textFieldController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              textFieldController.clear();
            },
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(textFieldController.text);
              textFieldController.clear();
            },
            child: const Text(
              'Save',
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<CategoryItem> categoryItems = context
        .watch<CategoriesProvider>()
        .getCategoryItems(widget.categoryName);
    // This will sort the category items by the checked property, with "unchecked" taking precedence
    categoryItems.sort(
      (item1, item2) {
        if (!item2.checked) {
          return 1;
        }
        return -1;
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () async {
              final newCategory = await _newCategoryDialogBuilder(
                context: context,
                textFieldController: textFieldController,
              );
              if (newCategory != null && newCategory.isNotEmpty) {
                if (context.mounted) {
                  context.read<CategoriesProvider>().addCategoryItem(
                      widget.categoryName,
                      CategoryItem(name: newCategory, id: 909, categoryId: 01));
                } else {
                  throw Exception('Context was not yet mounted');
                }
              }
            },
          )
        ],
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        margin: EdgeInsets.only(
            // top: 20,
            ),
        child: ListView.separated(
          itemCount: categoryItems.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(
            color: Colors.black,
          ),
          itemBuilder: (BuildContext context, int index) {
            final category = categoryItems[index];
            return Dismissible(
              key: Key(category.name),
              onDismissed: (direction) {
                // Remove the item from the data source.
                context
                    .read<CategoriesProvider>()
                    .deleteCategoryItem(widget.categoryName, category);
                // Then show a snackbar.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category.name} dismissed')),
                );
              },
              confirmDismiss: (direction) async {
                return await confirmDismissDialogBuilder(context: context);
              },
              background: Container(color: Colors.red),
              child: ListTile(
                trailing: Checkbox(
                  onChanged: (bool? value) {
                    if (value != null) {
                      context.read<CategoriesProvider>().editCategoryItem(
                          widget.categoryName, category.copy(checked: value));
                    }
                  },
                  value: category.checked,
                ),
                title: Text(
                  category.name,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
