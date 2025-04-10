import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/screens/Account/donation_history.dart';
import 'package:life_link/screens/Account/donation_status.dart';
import 'package:life_link/screens/Account/medical_collection.dart';
import 'package:life_link/screens/Auth/login_screen.dart';
import 'package:life_link/screens/account/personal_collection.dart';
import 'package:life_link/screens/account/personal_info_form_screen.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:life_link/widgets/appbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.isDonor, required this.userModel});

  bool isDonor;
  UserModel userModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imageURL;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      String? imageUrl =
          await UserService().fetchProfileImage(widget.userModel.id);
      if (imageUrl != null && mounted) {
        setState(() {
          _imageURL = imageUrl;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile image: $e");
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _uploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _uploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      File imageFile = File(pickedFile.path);

      String? imageUrl = await UserService()
          .uploadProfileImage(widget.userModel.id, imageFile, context);

      if (imageUrl != null && mounted) {
        setState(() {
          _imageURL = imageUrl;
        });
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kNoHeightAppbarWidget,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _profileImage(),
            Text(
              widget.userModel.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            _profilePageButton(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PersonalCollection()));
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
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              image: DecorationImage(
                image: _imageURL != null && _imageURL!.isNotEmpty
                    ? NetworkImage(_imageURL!)
                    : AssetImage('assets/images/default_profile.jpeg')
                        as ImageProvider,
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
                onPressed: _pickImage,
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
