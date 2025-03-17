import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/screens/Account/donation_history.dart';
import 'package:life_link/screens/Account/donation_status.dart';
import 'package:life_link/screens/Account/medical_collection.dart';
import 'package:life_link/screens/Auth/login_screen.dart';
import 'package:life_link/screens/account/personal_info_form_screen.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:life_link/widgets/appbar_widget.dart';

import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.isDonor, required this.userModel});

  bool isDonor;
  UserModel userModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _imageURL =
      "https://i.pinimg.com/736x/25/1c/e1/251ce139d8c07cbcc9daeca832851719.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kNoHeightAppbarWidget,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _profileImage(),
            _profilePageButton(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PersonalInfoFormScreen(
                            isDonor: widget.isDonor,
                            userModel: widget.userModel)));
              },
              icon: Icons.person,
              title: 'Personal Info',
            ),
            _profilePageButton(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MedicalCollection()));
              },
              icon: Icons.medical_information,
              title: 'Medical Info',
            ),
            _profilePageButton(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DonationStatus()));
              },
              icon: Icons.check_circle,
              title: 'Donation Status',
            ),
            _profilePageButton(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DonationHistory()));
              },
              icon: Icons.history,
              title: 'Donation History',
            ),
            _profilePageButton(
              onTap: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                          child: const Text(
                              'Do you want to change your password?'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  AuthService.resetPassword(
                                      AuthService.getLoggedUserEmail());
                                },
                                child: const Text('YES'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('NO'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: Icons.password,
              title: 'Change Password',
            ),
            _profilePageButton(
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                            child: const Text('Do you want to Logout?'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    AuthService.logoutUser().then((value) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                    });
                                  },
                                  child: const Text('YES'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('NO'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: Icons.logout,
                title: 'Logout')
          ],
        ),
      ),
    );
  }

  Widget _profileImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          _imageURL != null
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    image: DecorationImage(
                      image: NetworkImage(_imageURL!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/profile.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          Positioned(
            bottom: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              radius: 20,
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePageButton({
    required Function onTap,
    required IconData icon,
    required String title,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: kProfilePage,
        ),
        child: Row(
          children: [
            Icon(icon, color: kProfileIcon, size: 35),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
