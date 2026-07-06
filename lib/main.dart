import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

  debugShowCheckedModeBanner: false,

  theme: ThemeData(

    useMaterial3: true,

    colorSchemeSeed: Colors.blue,

    inputDecorationTheme: const InputDecorationTheme(

      border: OutlineInputBorder(),

      filled: true,

    ),

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        minimumSize: const Size(
          double.infinity,
          55,
        ),

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(
            12,
          ),

        ),
      ),
    ),
  ),
      //debugShowCheckedModeBanner: false,
      title: 'Flutter Chat',
      home: FirebaseAuth.instance.currentUser != null
    ? HomeScreen()
    : const LoginScreen(),
    );
  }
}