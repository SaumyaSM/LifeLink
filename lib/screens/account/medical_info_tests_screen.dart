import 'package:flutter/material.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/services/user_service.dart';

import '../../constants/colors.dart';
import '../../models/user_model.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/medical_tests_widget.dart';

class MedicalInfoTestsScreen extends StatefulWidget {
  MedicalInfoTestsScreen({super.key, required this.userModel});
  UserModel userModel;

  @override
  State<MedicalInfoTestsScreen> createState() => _MedicalInfoTestsScreenState();
}

class _MedicalInfoTestsScreenState extends State<MedicalInfoTestsScreen> {
  final Map<String, String?> uploadedFiles = {};
  final Map<String, bool> testCompletionStatus = {};

  final Map<String, String> uploadedFilesPaths = {}; // Store local file paths
  bool isUploading = false;

  // List of mandatory tests that must be completed
  final List<String> mandatoryTests = [
    'ABO Blood Typing',
    'Tissue Typing (HLA Antigens)',
  ];

  void updateTestStatus(String testName, bool isCompleted) {
    setState(() {
      testCompletionStatus[testName] = isCompleted;
    });
  }

  void updateFileUpload(String testName, String? fileName, String? filePath) {
    setState(() {
      uploadedFiles[testName] = fileName;
      if (filePath != null) {
        uploadedFilesPaths[testName] = filePath;
      }
    });
  }

  Future<void> handleSubmit() async {
    // First validate mandatory tests
    for (String mandatoryTest in mandatoryTests) {
      // Check if test is either not marked as completed or doesn't have an uploaded file
      if (!testCompletionStatus.containsKey(mandatoryTest) ||
          testCompletionStatus[mandatoryTest] != true ||
          uploadedFiles[mandatoryTest] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$mandatoryTest is mandatory and requires a document upload'),
            backgroundColor: kPinkColor,
          ),
        );
        return;
      }
    }

    // Validate other completed tests have corresponding documents
    bool canProceed = true;
    String missingTest = '';

    for (var entry in testCompletionStatus.entries) {
      if (entry.value && (uploadedFiles[entry.key] == null)) {
        canProceed = false;
        missingTest = entry.key;
        break;
      }
    }

    if (!canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload document for: $missingTest'),
          backgroundColor: kPinkColor,
        ),
      );
      return;
    }

    // Begin upload process
    setState(() {
      isUploading = true;
    });

    try {
      // Upload files to Firebase using the service method
      Map<String, String> uploadedUrls =
          await UserService.uploadMedicalDocuments(
              widget.userModel.id, uploadedFilesPaths);

      // Check if all required tests are completed
      bool allRequiredTestsCompleted =
          testCompletionStatus.values.every((status) => status == true);

      // Update the tests completion status
      await UserService.updateTestCompletionStatus(
          widget.userModel.id, allRequiredTestsCompleted);

      // Update the local user model
      Map<String, String> updatedMedicalDocuments = {
        ...widget.userModel.medicalDocuments
      };
      updatedMedicalDocuments.addAll(uploadedUrls);

      widget.userModel = widget.userModel.copyWith(
          medicalDocuments: updatedMedicalDocuments,
          isTestsCompleted: allRequiredTestsCompleted);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medical documents uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(userModel: widget.userModel),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading documents: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
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
                  Container(
                    padding: EdgeInsets.only(left: 21, top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Note: ABO Blood Typing and Tissue Typing (HLA Antigens) are mandatory.',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
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
                  isUploading
                      ? CircularProgressIndicator(color: kPinkColor)
                      : ButtonWidget(onTap: handleSubmit, title: 'Submit'),
                  SizedBox(height: 20),
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
              isMandatory: mandatoryTests.contains(test),
              onStatusChange: updateTestStatus,
              onFileUpload: (testName, fileName) {
                updateFileUpload(testName, fileName, null);
              },
              onFilePathSelected: (testName, fileName, filePath) {
                updateFileUpload(testName, fileName, filePath);
              },
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
