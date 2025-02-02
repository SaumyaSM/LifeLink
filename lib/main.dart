import 'package:flutter/material.dart';
import 'package:life_link/screens/home_screen.dart';
import 'package:life_link/screens/login_screen.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/screens/profile_screen.dart';
import 'package:life_link/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app after Firebase is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDonor = true; // Replace with dynamic logic if necessary
    int organCount = 2;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomeScreen(isDonor: isDonor, organCount: organCount),
    );
  }
}
