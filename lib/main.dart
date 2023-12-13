import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/supabase_provider.dart';
import 'providers/categories_provider.dart';
import 'utilities/local_data_accessor.dart';
import 'screens/category_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_scren.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize our local data accessor, which is used to read/write/delete local data
  await LocalDataAccessor().init();
  // await SupabaseProvider.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CategoriesProvider(
            localDataAccessor: LocalDataAccessor(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SupabaseProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: [
      GoRoute(
        name: 'splashScreen',
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        name: 'mainScreen',
        path: '/main-screen',
        builder: (BuildContext context, GoRouterState state) =>
            const MainScreen(title: 'Flutter Demo Home Page 2'),
      ),
      GoRoute(
        name: 'loginScreen',
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        name: 'categoryScreen',
        path: '/category/:categoryName',
        builder: (BuildContext context, GoRouterState state) => CategoryScreen(
          categoryName: state.pathParameters['categoryName']!,
        ),
      ),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// class HomePage extends StatefulWidget {
//   final String title;
//   const HomePage({super.key, required this.title});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late TextEditingController textFieldController;
//   @override
//   void initState() {
//     textFieldController = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // Clean up the controller when the widget is removed from the
//     // widget tree.
//     textFieldController.dispose();
//     super.dispose();
//   }

//   Future<String?> _dialogBuilder(
//       {required BuildContext context,
//       required TextEditingController textFieldController}) async {
//     return showDialog<String?>(
//       context: context,
//       builder: (context) => CupertinoAlertDialog(
//         title: Text('Enter new category you fucker:'),
//         content: CupertinoTextField(
//           autofocus: true,
//           controller: textFieldController,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               textFieldController.clear();
//             },
//             child: const Text(
//               'Cancel',
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(textFieldController.text);
//               textFieldController.clear();
//             },
//             child: const Text(
//               'Save',
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CategoriesProvider>(builder: (BuildContext context,
//         CategoriesProvider categoriesProvider, Widget? child) {
//       var categoryNames = categoriesProvider.getCategoryNames();
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.blue.shade700,
//           title: Text(
//             widget.title,
//             style: const TextStyle(
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: Container(),
//         drawer: CustomDrawer(
//           categoryNames: categoryNames,
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             final newCategory = await _dialogBuilder(
//               context: context,
//               textFieldController: textFieldController,
//             );
//             if (!categoryNames.contains(newCategory)) {
//               if (newCategory != null && newCategory.isNotEmpty) {
//                 setState(
//                   () {
//                     categoriesProvider.addCategory(newCategory);
//                   },
//                 );
//               }
//             } else {
//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content:
//                       Text('There is already a category with the same name'),
//                 ));
//               } else {
//                 print('Context not mounted');
//               }
//             }
//           },
//           tooltip: 'Add new category page',
//           child: const Icon(Icons.add),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       );
//     });
//   }
// }
