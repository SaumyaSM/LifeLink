import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/screens/Auth/login_screen.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:life_link/services/user_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../models/user_model.dart';

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

  getCurrentUser() async {
    if (!AuthService.isUserLogged()) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      });
      return;
    }

    await UserService.getUserData().then((UserModel userModel) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen(userModel: userModel)));
    }).catchError((error) {
      AuthService.logoutUser().then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/loading-screen.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: MediaQuery.of(context).size.width * 0.45,
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: kHomeColor3,
            size: 50,
          ),
        ),
      ],
    );
  }
}
