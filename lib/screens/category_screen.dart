import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../helpers/text_dialog_builder.dart';
import '../models/category_item.dart';
import '../providers/supabase_provider.dart';
import '../utilities/app_logger.dart';
import '../widgets/category_item_widget.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  const CategoryScreen(
      {super.key, required this.categoryName, required this.categoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late bool _isAdding;
  late Future<void> _initCategoryItemsData;
  late int _categoryIndex;
  late List<CategoryItem> _categoryItems;
  late TextEditingController textFieldController;
  @override
  void initState() {
    textFieldController = TextEditingController();
    _isAdding = false;
    _categoryIndex = context
        .read<SupabaseProvider>()
        .getCategoryIndex(categoryId: widget.categoryId);
    _initCategoryItemsData = _initCategoryItems();
    super.initState();
  }

  Future<void> _initCategoryItems() async {
    AppLogger().logger.i('Init category items');
    SupabaseProvider supabaseProvider = context.read<SupabaseProvider>();
    await supabaseProvider.getCategoryItems(categoryId: widget.categoryId);
    _categoryItems = supabaseProvider.categories[_categoryIndex].categoryItems;
  }

  Future<void> _refreshCategoryItems({bool fetchCategoryItems = false}) async {
    AppLogger().logger.i('Refreshing category items');
    SupabaseProvider supabaseProvider = context.read<SupabaseProvider>();
    if (fetchCategoryItems == true) {
      await supabaseProvider.getCategoryItems(categoryId: widget.categoryId);
    }
    setState(() {
      _categoryItems =
          supabaseProvider.categories[_categoryIndex].categoryItems;
    });
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

  Widget _listView(AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return ListView.separated(
        itemCount: _categoryItems.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.black,
        ),
        itemBuilder: (BuildContext context, int index) {
          return CategoryItemWidget(
            categoryItems: _categoryItems,
            categoryItemIndex: index,
            refreshCategoryItems: _refreshCategoryItems,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseProvider>(
        builder: (context, supabaseProvider, child) {
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
                ScaffoldMessengerState scaffoldMessenger =
                    ScaffoldMessenger.of(context);
                final newCategoryItemName = await textDialogBuilder(
                  title: 'Enter new item:',
                  context: context,
                  textFieldController: textFieldController,
                );
                if (newCategoryItemName != null &&
                    newCategoryItemName.isNotEmpty) {
                  setState(() {
                    _isAdding = true;
                  });
                  await supabaseProvider.createCategoryItem(
                      categoryItemName: newCategoryItemName,
                      categoryId: widget.categoryId,
                      scaffoldMessenger: scaffoldMessenger);
                  setState(() {
                    _isAdding = false;
                    _categoryItems = supabaseProvider
                        .categories[_categoryIndex].categoryItems;
                  });
                }
              },
            )
          ],
          backgroundColor: Colors.blue.shade700,
        ),
        body: FutureBuilder<void>(
          future: _initCategoryItemsData,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              color: Colors.black,
              backgroundColor: Colors.orangeAccent,
              onRefresh: () async =>
                  _refreshCategoryItems(fetchCategoryItems: true),
              child: _isAdding
                  ? _progressIndicationWidget('Adding Category ...')
                  : _listView(snapshot),
            );
          },
        ),
      );
    });
  }
}
