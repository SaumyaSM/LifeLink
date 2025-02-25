import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/account/personal_info_form_screen.dart';
import 'package:life_link/widgets/button_widget.dart';

class StartScreen extends StatefulWidget {
  UserModel userModel;
  StartScreen({super.key, required this.userModel});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                  gradient: kGradientLogin,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/LifeLink-Logo.PNG',
                        width: 70,
                        height: 70,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'LifeLink',
                        style: TextStyle(fontSize: 35, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40), topLeft: Radius.circular(40))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/people.png',
                      width: MediaQuery.of(context).size.width / 0.2,
                      height: MediaQuery.of(context).size.height / 5,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'You are....',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ButtonWidget(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PersonalInfoFormScreen(
                                        isDonor: true,
                                        userModel: widget.userModel,
                                      )));
                        },
                        title: 'Donator'),
                    SizedBox(
                      height: 20,
                    ),
                    ButtonWidget(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PersonalInfoFormScreen(
                                        isDonor: false,
                                        userModel: widget.userModel,
                                      )));
                        },
                        title: 'Recipient'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
