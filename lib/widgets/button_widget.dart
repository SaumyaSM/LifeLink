import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';

class ButtonWidget extends StatelessWidget {
  Function onTap;
  String title;
  ButtonWidget({super.key, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onTap(),
      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kOrangeColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
