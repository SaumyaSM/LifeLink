import 'package:flutter/material.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/account/medical_info_screen.dart';
import 'package:life_link/widgets/button_widget.dart';

import '../../constants/colors.dart';

class AskToFillMedicalInfoScreen extends StatelessWidget {
  UserModel userModel;
  AskToFillMedicalInfoScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 40, left: 50, right: 50),
            child: Column(
              children: [
                Center(
                  child: Image.asset('assets/images/no-data.jpg'),
                )
              ],
            ),
          ),
          Text('Please fill your medical info to access this feature!'),
          SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MedicalInfoScreen(userModel: userModel))),
              style:
                  TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kOrangeColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    'Fill Medical Info',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
