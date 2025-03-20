import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/account/medical_info_tests_screen.dart';
import '../../constants/colors.dart';
import '../../widgets/button_widget.dart';

class MedicalInfoScreen extends StatefulWidget {
  MedicalInfoScreen({super.key, required this.userModel});
  UserModel userModel;

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

final TextEditingController _hlaAController = TextEditingController();
final TextEditingController _hlaBController = TextEditingController();
final TextEditingController _hlaDRController = TextEditingController();

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  String? selectOrganType;
  final List<String> organTypes = [
    'Kidney',
    'Lung',
    'Part of Liver',
    'Part of Intestine',
    'Part of Pancreas'
  ];
  String? selectedBloodType;
  final List<String> bloodTypes = ['O', 'A', 'B', 'AB'];

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
      _showErrorMessage('Please select a blood group.');
      return;
    }

    if (selectOrganType == null) {
      _showErrorMessage('Please select an organ type.');
      return;
    }
    if (selectedBloodType == null) {
      _showErrorMessage('Please select a blood group.');
      return;
    }

    if (selectOrganType == null) {
      _showErrorMessage('Please select an organ type.');
      return;
    }

    if (_hlaAController.text.trim().isEmpty ||
        _hlaBController.text.trim().isEmpty ||
        _hlaDRController.text.trim().isEmpty) {
      _showErrorMessage('Please enter HLA typing for all loci.');
      return;
    }

    UserModel userModel = UserModel(
      id: widget.userModel.id,
      fullName: widget.userModel.fullName,
      dateOfBirth: widget.userModel.dateOfBirth,
      gender: widget.userModel.gender,
      nic: widget.userModel.nic,
      contact: widget.userModel.contact,
      address: widget.userModel.address,
      isDonor: widget.userModel.isDonor,
      bloodType: selectedBloodType!,
      organType: selectOrganType!,
      hlaTyping: {
        'A': _hlaAController.text.trim(),
        'B': _hlaBController.text.trim(),
        'C': _hlaBController.text.trim(),
        'DRB1': _hlaDRController.text.trim(),
        'DQB1': _hlaDRController.text.trim(),
      },
      medicalConditions: '', // Removed unnecessary data
      medications: '',
      allergies: '',
      medicalReports: [],
      isTestsCompleted: false,
      likes: [],
      history: [],
      city: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalInfoTestsScreen(userModel: userModel),
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
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _registerBanner(),
            Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Fill in your medical details',
                  style: TextStyle(
                    color: kPinkColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Organ Dropdown
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.userModel.isDonor
                        ? 'Donating Organ'
                        : 'Organ Needed',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectOrganType,
                    isExpanded: true,
                    underline: SizedBox(),
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

                SizedBox(height: 10),
                // Blood Group Dropdown
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blood Group',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBloodType,
                    isExpanded: true,
                    underline: SizedBox(),
                    hint: Text(
                      'Select Blood Group',
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

                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'HLA Typing',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please Enter your HLA Results according to your Report',
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                SizedBox(height: 15),
// HLA-A
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _hlaAController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'HLA-A ',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                SizedBox(height: 10),

// HLA-B
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _hlaBController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'HLA-B ',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _hlaBController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'HLA-C ',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                SizedBox(height: 10),

// HLA-DR
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _hlaDRController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'HLA-DRB1 ',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),

                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _hlaDRController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'HLA-DQB1 ',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 21),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Medical Reports',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
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
                            color: _fileName == null
                                ? Colors.grey.shade600
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.folder_open),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),
                // Next Button
                ButtonWidget(onTap: _validateAndProceed, title: 'Next'),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Banner Widget
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
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.userModel.isDonor ? 'DONATOR!' : 'RECIPIENT!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Image.asset(
            widget.userModel.isDonor
                ? 'assets/images/donator.png'
                : 'assets/images/recipient.png',
            height: MediaQuery.of(context).size.width * 0.2,
          ),
        ],
      ),
    );
  }
}
