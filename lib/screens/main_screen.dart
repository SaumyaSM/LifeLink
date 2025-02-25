import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/account/ask_to_fill_medical_info_screen.dart';
import 'package:life_link/screens/explore_screen.dart';
import 'package:life_link/screens/home_screen.dart';
import 'package:life_link/screens/matches_screen.dart';
import 'package:life_link/screens/notification_screen.dart';
import 'package:life_link/screens/account/profile_screen.dart';
import 'package:life_link/widgets/appbar_widget.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key, required this.userModel});

  UserModel userModel;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: kNoHeightAppbarWidget,
        body: [
          HomeScreen(userModel: widget.userModel),
          widget.userModel.bloodType != ''
              ? MatchesScreen(isDonor: widget.userModel.isDonor)
              : AskToFillMedicalInfoScreen(userModel: widget.userModel),
          widget.userModel.bloodType != ''
              ? ExploreScreen(isDonor: widget.userModel.isDonor)
              : AskToFillMedicalInfoScreen(userModel: widget.userModel),
          NotificationScreen(),
          ProfileScreen(isDonor: widget.userModel.isDonor),
        ][_currentPageIndex],
        bottomNavigationBar: _navBar(),
      ),
    );
  }

  Widget _navBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: kGradientNavBar,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(index: 0, icon: Icons.home_outlined),
          _navIcon(index: 1, icon: Icons.favorite_outline),
          _navIcon(index: 2, icon: Icons.search_outlined),
          _navIcon(index: 3, icon: Icons.notifications_none_outlined),
          _navIcon(index: 4, icon: Icons.person_outline_outlined),
        ],
      ),
    );
  }

  Widget _navIcon({
    required int index,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _currentPageIndex = index),
      child: Icon(
        icon,
        color: _currentPageIndex == index ? Colors.black : Colors.white,
        size: 30,
      ),
    );
  }
}
