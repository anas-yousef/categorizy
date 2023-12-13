import 'package:categorizy/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';
import '../utilities/supabase_api_utility.dart';
import '../widgets/custom_drawer_widget.dart';

class MainScreen extends StatefulWidget {
  final String title;
  const MainScreen({super.key, required this.title});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _isLoading;
  late TextEditingController textFieldController;
  @override
  void initState() {
    textFieldController = TextEditingController();
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textFieldController.dispose();
    super.dispose();
  }

  Future<String?> _dialogBuilder(
      {required BuildContext context,
      required TextEditingController textFieldController}) async {
    return showDialog<String?>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Enter new category you fucker:'),
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

  // This function is called if context is mounted!
  Future<void> createCategory(
      {required String categoryName, required BuildContext context}) async {
    // var res = await SupabaseApiUtility().fetchCategories();
    // print(res);
    // return;
    setState(() {
      _isLoading = true;
    });
    try {
      // TODO How to use catchError() of Future object
      await context
          .read<SupabaseProvider>()
          .createCategory(categoryName: categoryName, context: context);
    } on Exception catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      // TODO Should be using a logger
      print(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _progressIndicationWidget() {
    List<Widget> children = [
      const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Creating category...'),
      ),
    ];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(builder: (BuildContext context,
        CategoriesProvider categoriesProvider, Widget? child) {
      var categoryNames = categoriesProvider.getCategoryNames();
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: _isLoading ? _progressIndicationWidget() : Container(),
        drawer: CustomDrawer(
          categoryNames: categoryNames,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newCategory = await _dialogBuilder(
              context: context,
              textFieldController: textFieldController,
            );
            if (!categoryNames.contains(newCategory)) {
              if (newCategory != null && newCategory.isNotEmpty) {
                if (mounted) {
                  await createCategory(
                      categoryName: newCategory, context: context);
                } else {
                  print('Context not mounted, could not save to DB');
                }
                categoriesProvider.addCategory(newCategory);
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('There is already a category with the same name'),
                ));
              } else {
                print('Context not mounted');
              }
            }
          },
          tooltip: 'Add new category page',
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }
}
