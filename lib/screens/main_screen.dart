import 'package:categorizy/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../helpers/confirm_delete_dialog_builder.dart';
import '../helpers/text_dialog_builder.dart';
import '../utilities/app_logger.dart';

class MainScreen extends StatefulWidget {
  final String title;
  const MainScreen({super.key, required this.title});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _isAdding;
  late TextEditingController textFieldController;
  @override
  void initState() {
    textFieldController = TextEditingController();
    _isAdding = false;
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
        title: const Text('Enter new category:'),
        content: CupertinoTextField(
          autofocus: true,
          controller: textFieldController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              textFieldController.clear();
              AppLogger().logger.i('Cancelled');
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

  Future<void> createCategory({required String categoryName}) async {
    setState(() {
      _isAdding = true;
    });
    try {
      // TODO How to use catchError() of Future object
      ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
      await context.read<SupabaseProvider>().createCategory(
          categoryName: categoryName, scaffoldMessenger: scaffoldMessenger);
    } on Exception catch (error) {
      AppLogger().logger.e(error.toString());
    }
    setState(() {
      _isAdding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: CategoriesWidget(isAddingCategory: _isAdding),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCategory = await textDialogBuilder(
            title: 'Enter new category:',
            context: context,
            textFieldController: textFieldController,
          );
          if (newCategory != null && newCategory.isNotEmpty) {
            await createCategory(categoryName: newCategory);
          } else {
            AppLogger().logger.i('Category can\'t be empty');
          }
        },
        tooltip: 'Add new category page',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CategoriesWidget extends StatefulWidget {
  final bool isAddingCategory;
  const CategoriesWidget({super.key, required this.isAddingCategory});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  late Future<void> _initCategoriesData;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _initCategoriesData = _refreshCategories();
  }

  Future<void> _refreshCategories() async {
    AppLogger().logger.i('Refreshing categories');
    await context.read<SupabaseProvider>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _initCategoriesData,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.black,
            backgroundColor: Colors.purpleAccent,
            onRefresh: _refreshCategories,
            child: CategoriesBuilder(
              isAddingCategory: widget.isAddingCategory,
              snapshot: snapshot,
            ),
          );
        });
  }
}

class CategoriesBuilder extends StatefulWidget {
  final AsyncSnapshot<void> snapshot;
  final bool isAddingCategory;
  const CategoriesBuilder({
    super.key,
    required this.snapshot,
    required this.isAddingCategory,
  });

  @override
  State<CategoriesBuilder> createState() => _CategoriesBuilderState();
}

class _CategoriesBuilderState extends State<CategoriesBuilder> {
  late bool _isDeleting;
  @override
  void initState() {
    super.initState();
    _isDeleting = false;
  }

  Widget _progressIndicationWidget(String message) {
    List<Widget> children = [
      const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(message),
      ),
    ];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _listView(
      AsyncSnapshot<void> snapshot, SupabaseProvider supabaseProvider) {
    if (snapshot.connectionState == ConnectionState.done) {
      var categories = supabaseProvider.categories;
      return ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(Icons.face_2_outlined),
            title: Text(categories[index].name),
            onTap: () {
              context.pushNamed(
                'categoryScreen',
                pathParameters: {
                  'categoryId': '${categories[index].id}',
                  'categoryName': categories[index].name,
                },
              );
            },
            onLongPress: () async {
              ScaffoldMessengerState scaffoldMessenger =
                  ScaffoldMessenger.of(context);
              var result = await confirmDismissDialogBuilder(context: context);
              if (result == true) {
                setState(() {
                  _isDeleting = true;
                });
                await supabaseProvider.deleteCategory(
                  categoryName: categories[index].name,
                  categoryId: categories[index].id,
                  scaffoldMessenger: scaffoldMessenger,
                );

                setState(() {
                  _isDeleting = false;
                });
              } else {
                AppLogger().logger.i('Decided not to delete category');
              }
            },
          );
        },
      );
    } else if (snapshot.hasError) {
      AppLogger().logger.e('${snapshot.error}');
      return Center(
        child: Text('Error: ${snapshot.error}'),
      );
    } else {
      return _progressIndicationWidget('Loading data...');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) {
      return _progressIndicationWidget('Deleting category...');
    } else if (widget.isAddingCategory) {
      return _progressIndicationWidget('Creating category...');
    }
    return Consumer<SupabaseProvider>(
        builder: (context, supabaseProvider, child) {
      return _listView(widget.snapshot, supabaseProvider);
    });
  }
}
