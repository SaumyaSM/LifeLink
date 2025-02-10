import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../widgets/button_widget.dart';
import '../widgets/medical_tests_widget.dart';

class MedicalInfoTests extends StatefulWidget {
  MedicalInfoTests({super.key, required this.isDonor});
  bool isDonor;

  @override
  State<MedicalInfoTests> createState() => _MedicalInfoTestsState();
}

class _MedicalInfoTestsState extends State<MedicalInfoTests> {
  final Map<String, String?> uploadedFiles = {};
  final Map<String, bool> testCompletionStatus = {};

  void updateTestStatus(String testName, bool isCompleted) {
    setState(() {
      testCompletionStatus[testName] = isCompleted;
    });
  }

  void updateFileUpload(String testName, String? fileName) {
    setState(() {
      uploadedFiles[testName] = fileName;
    });
  }

  void handleSubmit() {
    for (var entry in testCompletionStatus.entries) {
      if (entry.value && (uploadedFiles[entry.key] == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload document for: ${entry.key}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalInfoTests(isDonor: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          _registerBanner(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Test status',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: kPinkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(left: 21),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Instruction: Please confirm if the following tests have been completed. If completed, upload the relevant reports for validation.',
                      style: TextStyle(fontSize: 14, color: Colors.redAccent),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTestSection('Immunological Tests', [
                    'ABO Blood Typing',
                    'Tissue Typing (HLA Antigens)',
                    'Family Analysis'
                  ]),
                  _buildTestSection('Laboratory Tests', [
                    'Hematological System Assessment',
                    'Clotting Mechanism Assessment',
                    'Kidney Function\n(Glomerular Filtration Rate - GFR)',
                    'Electrolyte Balance Screening',
                    'Glucose Intolerance Screening',
                    'Venereal Disease Screening',
                    'Pancreatitis Screening',
                    'Liver Function Tests',
                    'Hepatitis B Screening',
                    'Viral Activity Screening\n(CMV, HIV)'
                  ]),
                  _buildTestSection('Urine Tests', [
                    'Kidney Disease Screening (ACR)',
                    'Urinary Tract Infection Screening',
                    'Protein Excretion &\nCreatinine Clearance'
                  ]),
                  _buildTestSection('Other Tests', [
                    'Medical History & Physical Examination',
                    'EKG (Electrocardiogram)\n-Heart Function Assessment',
                    'Chest X-Ray - Lung Assessment',
                    'Psychological Evaluation',
                    'Gynecological Exam & Mammography\n(For Female Donors)',
                    'Intravenous Pyelography (IVP)\n-Kidney Structure Assessment',
                    'Helical CT Scan\n-Kidney Internal Structure Evaluation',
                    'Renal Arteriogram\n-Kidney Blood Vessel &\nVascular Disease Assessment',
                    'Financial Consultation'
                  ]),
                  SizedBox(height: 10),
                  ButtonWidget(onTap: handleSubmit, title: 'Submit'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTestSection(String title, List<String> tests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 21),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        ...tests.map((test) => MedicalTestsWidget(
              statusLabel: test,
              onStatusChange: updateTestStatus,
              onFileUpload: updateFileUpload,
            )),
        SizedBox(height: 20),
      ],
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
          SizedBox(height: 5),
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
