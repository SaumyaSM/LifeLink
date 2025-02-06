import 'package:flutter/material.dart';
import 'package:life_link/screens/explore_screen.dart';
import 'package:life_link/screens/medical_info.dart';
import 'package:life_link/screens/login_screen.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/screens/personal_info_screen.dart';
import 'package:life_link/screens/profile_screen.dart';
import 'package:life_link/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_link/screens/start_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool isDonor = true;

  // Run the app after Firebase is initialized
  runApp(MyApp(isDonor: isDonor));
}

class MyApp extends StatelessWidget {
  final bool isDonor;
  const MyApp({super.key, required this.isDonor});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      // home: MedicalInfo(isDonor: false),
      // home: ProfileScreen(isDonor: isDonor),
      // home: ExploreScreen(isDonor: isDonor),
      home: StartScreen(),
    );
  }
}
