import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:life_link/screens/medical_info-tests.dart';
import 'package:life_link/widgets/medical_tests_widget.dart';

import '../constants/colors.dart';
import '../widgets/button_widget.dart';
import '../widgets/textbox_widget.dart';
import 'home_screen.dart';

class MedicalInfo extends StatefulWidget {
  MedicalInfo({super.key, required this.isDonor});
  bool isDonor;

  @override
  State<MedicalInfo> createState() => _MedicalInfoState();
}

class _MedicalInfoState extends State<MedicalInfo> {
  TextEditingController medicalConditions = TextEditingController();
  TextEditingController medications = TextEditingController();
  TextEditingController allergies = TextEditingController();

  String? selectOrganType;
  final List<String> organTypes = [
    'Kideny',
    'Lung',
    'Part of Liver',
    'Part of Intestine',
    'Paret of Pancrease'
  ];
  String? selectedBloodType; // Selected value
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  void _validateAndProceed() {
    if (selectedBloodType == null) {
      _showErrorMessage('Please select a blood type.');
      return;
    }

    if (selectOrganType == null) {
      _showErrorMessage('Please select an organ type.');
      return;
    }

    if (medicalConditions.text.isEmpty) {
      _showErrorMessage('Please enter your current medical conditions.');
      return;
    }

    if (medications.text.isEmpty) {
      _showErrorMessage('Please enter your list of medications.');
      return;
    }

    if (allergies.text.isEmpty) {
      _showErrorMessage('Please enter your allergies.');
      return;
    }

    if (_fileName == null) {
      _showErrorMessage('Please upload a medical report.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalInfoTests(isDonor: widget.isDonor),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kPinkColor,
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
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Fill in your medical details',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: kPinkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blood Type',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBloodType,
                    isExpanded: true,
                    underline: SizedBox(), // Remove the default underline
                    hint: Text(
                      'Select Blood Type',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    icon: Icon(Icons.arrow_drop_down),
                    onChanged: (value) {
                      setState(() {
                        selectedBloodType = value;
                      });
                    },
                    items: bloodTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.isDonor ? ' Donating Organ' : ' Organ Needed',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectOrganType,
                    isExpanded: true,
                    underline: SizedBox(), // Remove the default underline
                    hint: Text(
                      'Select Organ Type',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    icon: Icon(Icons.arrow_drop_down),
                    onChanged: (value) {
                      setState(() {
                        selectOrganType = value;
                      });
                    },
                    items: organTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextBox(
                    label: 'Current Medical Conditions',
                    controller: medicalConditions),
                CustomTextBox(
                    label: 'List of Medications', controller: medications),
                CustomTextBox(label: 'Allergies', controller: allergies),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Medical Reports',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fileName ?? 'Select File',
                          style: TextStyle(
                            color:
                                _fileName == null ? Colors.grey : Colors.black,
                          ),
                        ),
                        Icon(Icons.folder_open),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ButtonWidget(onTap: _validateAndProceed, title: 'Next'),
              ],
            )
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
