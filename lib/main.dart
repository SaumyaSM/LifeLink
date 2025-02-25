import 'package:flutter/material.dart';
import 'package:life_link/screens/Auth/password_reset.dart';
import 'package:life_link/screens/Auth/loading_screen.dart';
import 'package:life_link/screens/explore_screen.dart';
import 'package:life_link/screens/account/medical_info_tests_screen.dart';
import 'package:life_link/screens/account/medical_info_screen.dart';
import 'package:life_link/screens/Auth/login_screen.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/screens/account/personal_info_form_screen.dart';
import 'package:life_link/screens/account/profile_screen.dart';
import 'package:life_link/screens/auth/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_link/screens/account/start_screen.dart';
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
      // home: MedicalInfo(isDonor: isDonor),
      // home: ForgotPassword(),
      home: LoadingScreen(),
      // home: MedicalInfoTests(isDonor: isDonor),
    );
  }
}
