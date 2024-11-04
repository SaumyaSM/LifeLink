import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';

class GoogleButtonWidget extends StatelessWidget {
  Function onTap;
  GoogleButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onTap(),
      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kOrangeColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google.png',
              width: 25,
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
