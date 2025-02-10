import 'package:flutter/material.dart';
import 'package:life_link/screens/home_screen.dart';
import 'package:life_link/widgets/button_widget.dart';
import 'package:life_link/widgets/textbox_widget.dart';

import '../constants/colors.dart';

class PersonalInfoScreen extends StatefulWidget {
  PersonalInfoScreen({super.key, required this.isDonor});

  bool isDonor;

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  TextEditingController fullName = TextEditingController();
  TextEditingController nic = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController address = TextEditingController();

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

  bool validateForm() {
    if (fullName.text.isEmpty) {
      _showErrorDialog("Full Name cannot be empty");
      return false;
    }
    if (selectedDate == null) {
      _showErrorDialog("Please select a Date of Birth");
      return false;
    }
    if (selectedGender == null) {
      _showErrorDialog("Please select a Gender");
      return false;
    }
    if (!validateNIC(nic.text)) {
      _showErrorDialog("Invalid NIC format");
      return false;
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(contact.text)) {
      _showErrorDialog(
          "Enter a valid Contact number (only digits, at least 10 characters)");
      return false;
    }
    if (address.text.isEmpty) {
      _showErrorDialog("Address cannot be empty");
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: kRedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _registerBanner(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Fill in your personal details',
              textAlign: TextAlign.left,
              style: TextStyle(color: kPinkColor, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            CustomTextBox(
              controller: fullName,
              label: 'Full Name',
            ),
            Container(
              padding: EdgeInsets.only(left: 21),
              alignment: Alignment.centerLeft,
              child: Text(
                'Date of Birth',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey),
                    SizedBox(width: 12),
                    Text(
                      selectedDate ?? 'Select Date',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 21),
              alignment: Alignment.centerLeft,
              child: Text(
                'Gender',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            SizedBox(
              height: 10,
            ),
            CustomTextBox(label: 'NIC', controller: nic),
            CustomTextBox(
                controller: contact,
                label: 'Contact',
                keyboardType: TextInputType.number),
            CustomTextBox(
              controller: address,
              label: 'Address',
            ),
            SizedBox(
              height: 10,
            ),
            ButtonWidget(
              onTap: () {
                if (validateForm()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(isDonor: true, organCount: 2),
                    ),
                  );
                }
              },
              title: 'Register',
            )
          ],
        ),
      ),
    );
  }

  Widget _genderButton({required String gender, required IconData icon}) {
    final bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.43,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Color(0xFFEBEBEB),
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
              size: 30,
            ),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _registerBanner() {
    return Container(
      width: double.infinity,
      height: 170,
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
            offset: Offset(0, 1), // changes position of shadow
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
          SizedBox(
            height: 5,
          ),
          Image.asset(
            widget.isDonor
                ? 'assets/images/donator.png'
                : 'assets/images/recipient.png',
            height: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
    );
  }
}
