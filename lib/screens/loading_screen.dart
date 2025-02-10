import 'package:flutter/material.dart';
import 'package:life_link/screens/login_screen.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/services/auth_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() {
    Future.delayed(const Duration(seconds: 2), () {
      if (AuthService.isUserLogged()) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/loading-screen.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
