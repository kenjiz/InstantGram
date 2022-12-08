import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

import 'state/auth/providers/auth_state_provider.dart';
import 'state/auth/providers/is_logged_in_provider.dart';
import 'state/providers/is_loading_provider.dart';
import 'views/components/loading/loading_screen.dart';
import 'views/login/login_view.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        indicatorColor: Colors.blueGrey,
      ),
      home: Consumer(
        builder: (context, ref, child) {
          final isLoggedIn = ref.watch(isLoggedInProvider);
          ref.listen<bool>(isLoadingProvider, (_, isLoading) {
            isLoading
                ? LoadingScreen.instance.show(context: context)
                : LoadingScreen.instance.hide();
          });
          return isLoggedIn ? const MainView() : const LoginView();
        },
      ),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main View'),
      ),
      body: Center(
        child: Consumer(builder: (_, ref, __) {
          return ElevatedButton(
            onPressed: ref.read(authStateProvider.notifier).logOut,
            child: const Text('Logout'),
          );
        }),
      ),
    );
  }
}
