import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/screens/explore_screen.dart';
import 'package:life_link/screens/home_screen.dart';
import 'package:life_link/screens/matches_screen.dart';
import 'package:life_link/screens/profile_screen.dart';
import 'package:life_link/widgets/appbar_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPageIndex = 0;
  bool _isDonor = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: kNoHeightAppbarWidget,
        body: [
          HomeScreen(isDonor: _isDonor, organCount: 2),
          MatchesScreen(isDonor: _isDonor),
          ExploreScreen(isDonor: _isDonor),
          ProfileScreen(isDonor: _isDonor),
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
          _navIcon(index: 3, icon: Icons.person_outline_outlined),
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
