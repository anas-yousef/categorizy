import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/supabase_provider.dart';
import 'providers/categories_provider.dart';
import 'utilities/local_data_accessor.dart';
import 'screens/category_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_scren.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
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
            const MainScreen(title: 'Categorizy'),
      ),
      GoRoute(
        name: 'loginScreen',
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        name: 'categoryScreen',
        path: '/category/:categoryId/:categoryName',
        builder: (BuildContext context, GoRouterState state) => CategoryScreen(
          categoryId: int.parse(state.pathParameters['categoryId']!),
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
