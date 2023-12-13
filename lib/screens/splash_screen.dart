import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/utilities/supabase_api_utility.dart';
import '../providers/supabase_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Future<Supabase> supabaseInitializer;
  @override
  void initState() {
    supabaseInitializer = SupabaseApiUtility().getSupabaseInitializer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final session = SupabaseProvider.supabaseClient.auth.currentSession;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: FutureBuilder<Supabase>(
            future: supabaseInitializer,
            builder: (BuildContext context, AsyncSnapshot<Supabase> snapshot) {
              // The default is to show the CircularProgressIndicator
              List<Widget> children = [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ];
              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    SupabaseApiUtility().setSupabaseClient();
                    final session =
                        SupabaseApiUtility().supabaseClient.auth.currentSession;
                    if (session != null) {
                      context.pushReplacementNamed('mainScreen');
                    } else {
                      context.pushReplacementNamed('loginScreen');
                    }
                  },
                );
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
