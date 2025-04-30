import 'package:flutter/material.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/widgets/google_place_autocomplete_widget.dart';
import 'package:life_link/services/toast_service.dart';
import 'package:life_link/services/user_service.dart';
import 'package:life_link/widgets/button_widget.dart';
import 'package:life_link/widgets/loading_widget.dart';
import 'package:life_link/widgets/textbox_widget.dart';

import '../../constants/colors.dart';

class PersonalInfoFormScreen extends StatefulWidget {
  const PersonalInfoFormScreen(
      {Key? key, required this.isDonor, required this.userModel})
      : super(key: key);

  final bool isDonor;
  final UserModel userModel;

  @override
  State<PersonalInfoFormScreen> createState() => _PersonalInfoFormScreenState();
}

class _PersonalInfoFormScreenState extends State<PersonalInfoFormScreen> {
  bool isLoading = false;

  final TextEditingController fullName = TextEditingController();
  final TextEditingController nic = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController city = TextEditingController();

  final FocusNode addressFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();

  String? selectedDate;
  String? selectedGender;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  bool validateNIC(String nic) {
    RegExp nicPattern = RegExp(
      r"^(([5,6,7,8,9]{1})([0-9]{1})([0,1,2,3,5,6,7,8]{1})([0-9]{6})([vVxX]))|(([1,2]{1})([0,9]{1})([0-9]{2})([0,1,2,3,5,6,7,8]{1})([0-9]{7}))$",
      caseSensitive: false,
      multiLine: false,
    );

    return nicPattern.hasMatch(nic);
  }

  void validateForm() {
    if (fullName.text.isEmpty) {
      _showErrorDialog("Full Name cannot be empty");
      return;
    }
    if (selectedDate == null) {
      _showErrorDialog("Please select a Date of Birth");
      return;
    }
    if (selectedGender == null) {
      _showErrorDialog("Please select a Gender");
      return;
    }
    if (nic.text.isEmpty) {
      _showErrorDialog("Please enter your NIC");
      return;
    }
    if (!validateNIC(nic.text)) {
      _showErrorDialog("Invalid NIC format");
      return;
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(contact.text)) {
      _showErrorDialog(
          "Enter a valid Contact number (only digits, at least 10 characters)");
      return;
    }
    if (address.text.isEmpty) {
      _showErrorDialog("Address cannot be empty");
      return;
    }
    if (city.text.isEmpty) {
      _showErrorDialog("Please select your city");
      return;
    }

    setPersonalData();
  }

  void setPersonalData() async {
    setState(() => isLoading = true);

    UserModel userModel = UserModel(
      id: widget.userModel.id,
      fullName: fullName.text.trim(),
      dateOfBirth: selectedDate!,
      gender: selectedGender!,
      nic: nic.text.trim(),
      contact: contact.text.trim(),
      address: address.text.trim(),
      city: city.text.trim(),
      isDonor: widget.isDonor,
      bloodType: '',
      organType: '',
      isTestsCompleted: false,
      history: [],
      hlaTyping: {},
      waitingTime: 0,
      imageUrl: '',
    );

    await UserService.updateUserData(userModel).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(userModel: userModel),
        ),
      );
    }).catchError((error) {
      setState(() => isLoading = false);
      ToastService.displayErrorMotionToast(
          context: context, description: 'Something went Wrong!');
    });
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: kRedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get available screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;

    // Adjust banner height based on available space
    final bannerHeight = screenHeight * 0.15; // Use percentage of screen height

    return LoadingWidget(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _registerBanner(height: bannerHeight),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Fill in your personal details',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: kPinkColor, fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Form fields with padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextBox(
                              controller: fullName,
                              label: 'Full Name',
                            ),

                            Container(
                              padding: const EdgeInsets.only(left: 5),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Date of Birth',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),

                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Text(
                                      selectedDate ?? 'Select Date',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.only(left: 5),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Gender',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Gender selection row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _genderButton(
                                  gender: 'Female',
                                  icon: Icons.female,
                                ),
                                _genderButton(
                                  gender: 'Male',
                                  icon: Icons.male,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Remaining form fields
                            CustomTextBox(label: 'NIC', controller: nic),
                            CustomTextBox(
                                controller: contact,
                                label: 'Contact',
                                keyboardType: TextInputType.number),
                            CustomTextBox(
                              controller: address,
                              label: 'Address',
                              focusNode: addressFocusNode,
                            ),
                            const SizedBox(height: 10),

                            GooglePlaceAutoCompleteWidget(
                              controller: city,
                              focusNode: cityFocusNode,
                              onPlaceSelected: (Prediction prediction) {
                                setState(() {
                                  city.text = prediction.description ?? '';
                                });
                                FocusScope.of(context).unfocus();
                              },
                              label: 'City',
                            ),

                            // Add some padding at the bottom
                            const SizedBox(height: 20),

                            // Register button with key for testing
                            Center(
                              child: ButtonWidget(
                                key: const Key('registerButton'),
                                onTap: validateForm,
                                title: 'Register',
                              ),
                            ),

                            // Add extra padding at the bottom
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _genderButton({required String gender, required IconData icon}) {
    final bool isSelected = selectedGender == gender;
    final width =
        (MediaQuery.of(context).size.width - 48) / 2; // Account for padding

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black,
              size: 28, // Slightly reduced size
            ),
            const SizedBox(width: 4),
            Text(
              gender,
              style: TextStyle(
                fontSize: 15, // Slightly reduced size
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerBanner({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: kGradientRegister,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(94),
          bottomRight: Radius.circular(94),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isDonor ? 'DONATOR!' : 'RECIPIENT!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Image.asset(
            widget.isDonor
                ? 'assets/images/donator.png'
                : 'assets/images/recipient.png',
            height:
                height * 0.5, // Dynamically size image based on banner height
          ),
        ],
      ),
    );
  }
}
