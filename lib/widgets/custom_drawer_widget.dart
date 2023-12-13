import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';
import '../helpers/confirm_delete_dialog_builder.dart';

class CustomDrawer extends StatelessWidget {
  final List<String> categoryNames;
  const CustomDrawer({super.key, required this.categoryNames});

  Widget buildHeader(BuildContext context) {
    return Container();
  }

  Widget buildMenuItems(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Wrap(
          runSpacing: 16,
          children: categoryNames
              .map(
                (String categoryName) => ListTile(
                  leading: const Icon(Icons.face_2_outlined),
                  title: Text(categoryName),
                  onTap: () {
                    context.pushNamed('categoryScreen',
                        pathParameters: {'categoryName': categoryName});
                  },
                  onLongPress: () async {
                    var result =
                        await confirmDismissDialogBuilder(context: context);
                    if (result == true) {
                      if (context.mounted) {
                        context
                            .read<CategoriesProvider>()
                            .deleteCategory(categoryName);
                      } else {
                        throw Exception('Context was not yet mounted');
                      }
                    } else {
                      print('Decided not to delete category');
                    }
                  },
                ),
              )
              .toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        buildHeader(context),
        buildMenuItems(context),
      ],
    );
  }
}
