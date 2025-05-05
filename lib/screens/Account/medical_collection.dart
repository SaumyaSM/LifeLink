import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/user_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../widgets/document_viewer_widget.dart';

class MedicalCollection extends StatefulWidget {
  const MedicalCollection({super.key});

  @override
  State<MedicalCollection> createState() => _MedicalCollectionState();
}

class _MedicalCollectionState extends State<MedicalCollection> {
  UserModel? userModel;
  bool isLoading = true;
  bool isEditing = false;
  bool isUploading = false;

  // Controllers for editable fields
  final _hlaAController = TextEditingController();
  final _hlaBController = TextEditingController();
  final _hlaCController = TextEditingController();
  final _hlaDRB1Controller = TextEditingController();
  final _hlaDQB1Controller = TextEditingController();
  final _waitingTimeController = TextEditingController();

  String? selectedOrganType;
  String? selectedBloodType;

  // Store local file paths for new uploads
  final Map<String, String> uploadedFilesPaths = {};

  // List of all tests categorized
  final Map<String, List<String>> testCategories = {
    'Immunological Tests': [
      'ABO Blood Typing',
      'Tissue Typing (HLA Antigens)',
      'Family Analysis'
    ],
    'Laboratory Tests': [
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
    ],
    'Urine Tests': [
      'Kidney Disease Screening (ACR)',
      'Urinary Tract Infection Screening',
      'Protein Excretion &\nCreatinine Clearance'
    ],
    'Other Tests': [
      'Medical History & Physical Examination',
      'EKG (Electrocardiogram)\n-Heart Function Assessment',
      'Chest X-Ray - Lung Assessment',
      'Psychological Evaluation',
      'Gynecological Exam & Mammography\n(For Female Donors)',
      'Intravenous Pyelography (IVP)\n-Kidney Structure Assessment',
      'Helical CT Scan\n-Kidney Internal Structure Evaluation',
      'Renal Arteriogram\n-Kidney Blood Vessel &\nVascular Disease Assessment',
      'Financial Consultation'
    ]
  };

  // List of mandatory tests that must be completed
  final List<String> mandatoryTests = [
    'ABO Blood Typing',
    'Tissue Typing (HLA Antigens)',
  ];

  final List<String> organTypes = [
    'Kidney',
    'Lung',
    'Part of Liver',
    'Part of Intestine',
    'Part of Pancreas'
  ];
  final List<String> bloodTypes = ['O', 'A', 'B', 'AB'];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    UserModel? fetchedUser = await UserService.getUserData();
    if (fetchedUser != null) {
      _hlaAController.text = fetchedUser.hlaTyping['A'] ?? '';
      _hlaBController.text = fetchedUser.hlaTyping['B'] ?? '';
      _hlaCController.text = fetchedUser.hlaTyping['C'] ?? '';
      _hlaDRB1Controller.text = fetchedUser.hlaTyping['DRB1'] ?? '';
      _hlaDQB1Controller.text = fetchedUser.hlaTyping['DQB1'] ?? '';
      _waitingTimeController.text = fetchedUser.waitingTime.toString();

      setState(() {
        userModel = fetchedUser;
        selectedOrganType = fetchedUser.organType;
        selectedBloodType = fetchedUser.bloodType;
        isLoading = false;
      });
    }
  }

  Future<void> saveChanges() async {
    if (userModel != null) {
      UserModel updatedUser = userModel!.copyWith(
        organType: selectedOrganType!,
        bloodType: selectedBloodType!,
        hlaTyping: {
          'A': _hlaAController.text.trim(),
          'B': _hlaBController.text.trim(),
          'C': _hlaCController.text.trim(),
          'DRB1': _hlaDRB1Controller.text.trim(),
          'DQB1': _hlaDQB1Controller.text.trim(),
        },
        waitingTime: int.tryParse(_waitingTimeController.text.trim()) ?? 0,
      );

      await UserService.updateUserData(updatedUser);
      setState(() {
        userModel = updatedUser;
        isEditing = false;
      });
    }
  }

  Future<void> uploadDocuments() async {
    if (userModel == null || uploadedFilesPaths.isEmpty) return;

    setState(() {
      isUploading = true;
    });

    try {
      // Upload files to Firebase using the service method
      Map<String, String> uploadedUrls =
          await UserService.uploadMedicalDocuments(
              userModel!.id, uploadedFilesPaths);

      // Update the local user model
      Map<String, String> updatedMedicalDocuments = {
        ...userModel!.medicalDocuments
      };
      updatedMedicalDocuments.addAll(uploadedUrls);

      // Update user in database
      UserModel updatedUser = userModel!.copyWith(
        medicalDocuments: updatedMedicalDocuments,
      );
      await UserService.updateUserData(updatedUser);

      // Update local state
      setState(() {
        userModel = updatedUser;
        uploadedFilesPaths.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical documents updated successfully!'),
          backgroundColor: Colors.green,
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

  Future<void> selectFile(String testName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      String path = result.files.single.path!;
      String fileName = result.files.single.name;

      setState(() {
        uploadedFilesPaths[testName] = path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: $fileName'),
          action: SnackBarAction(
            label: 'Upload Now',
            onPressed: uploadDocuments,
          ),
        ),
      );
    }
  }

  void removeDocument(String testName) async {
    if (userModel == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Document"),
        content: const Text("Are you sure you want to remove this document?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Remove from Firebase Storage
                await UserService.removeMedicalDocument(
                    userModel!.id, testName);

                // Update local model
                Map<String, String> updatedDocs = {
                  ...userModel!.medicalDocuments
                };
                updatedDocs.remove(testName);

                UserModel updatedUser = userModel!.copyWith(
                  medicalDocuments: updatedDocs,
                );

                await UserService.updateUserData(updatedUser);

                setState(() {
                  userModel = updatedUser;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error removing document: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> viewDocument(String testName, String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewer(
          url: url,
          testName: testName,
        ),
      ),
    );
  }

  bool isTestCompleted(String testName) {
    if (userModel == null) return false;

    // Check if document exists for this test
    return userModel!.medicalDocuments.containsKey(testName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPinkColor,
        title: const Text("Medical Info"),
        actions: [
          if (!isLoading && userModel != null && uploadedFilesPaths.isNotEmpty)
            IconButton(
              icon: isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              onPressed: isUploading ? null : uploadDocuments,
            ),
          if (!isLoading && userModel != null)
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  saveChanges();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userModel == null
              ? const Center(child: Text("User not found"))
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Material(
                        color: kPinkColor.withOpacity(0.1),
                        child: const TabBar(
                          labelColor: kPinkColor,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: "Personal Medical Data"),
                            Tab(text: "Test Documents"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildPersonalMedicalTab(),
                            _buildTestDocumentsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPersonalMedicalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildDropdownTile(
                "Organ Type",
                organTypes,
                selectedOrganType,
                Icons.health_and_safety,
                (value) {
                  setState(() => selectedOrganType = value);
                },
              ),
              const Divider(),
              _buildDropdownTile(
                "Blood Group",
                bloodTypes,
                selectedBloodType,
                Icons.bloodtype,
                (value) {
                  setState(() => selectedBloodType = value);
                },
              ),
              const Divider(),
              _buildEditableTile(
                "HLA-A",
                _hlaAController,
                userModel!.hlaTyping['A'] ?? '',
                Icons.biotech,
              ),
              const Divider(),
              _buildEditableTile(
                "HLA-B",
                _hlaBController,
                userModel!.hlaTyping['B'] ?? '',
                Icons.biotech,
              ),
              const Divider(),
              _buildEditableTile(
                "HLA-C",
                _hlaCController,
                userModel!.hlaTyping['C'] ?? '',
                Icons.biotech,
              ),
              const Divider(),
              _buildEditableTile(
                "HLA-DRB1",
                _hlaDRB1Controller,
                userModel!.hlaTyping['DRB1'] ?? '',
                Icons.biotech,
              ),
              const Divider(),
              _buildEditableTile(
                "HLA-DQB1",
                _hlaDQB1Controller,
                userModel!.hlaTyping['DQB1'] ?? '',
                Icons.biotech,
              ),
              const Divider(),
              if (!(userModel?.isDonor ?? false))
                _buildEditableTile(
                  "Waiting Time (Days)",
                  _waitingTimeController,
                  userModel!.waitingTime.toString(),
                  Icons.hourglass_bottom,
                  isNumeric: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestDocumentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Test Documents",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPinkColor,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Please upload documents for completed tests. Mandatory tests are marked with *",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var category in testCategories.keys)
                  _buildTestCategory(category, testCategories[category]!),
              ],
            ),
          ),
          if (uploadedFilesPaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUploading ? null : uploadDocuments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPinkColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Upload All Selected Documents",
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestCategory(String category, List<String> tests) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: kPinkColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...tests.map((test) => _buildTestItem(test)),
        ],
      ),
    );
  }

  Widget _buildTestItem(String testName) {
    bool isMandatory = mandatoryTests.contains(testName);
    bool isCompleted = isTestCompleted(testName);
    bool hasNewUpload = uploadedFilesPaths.containsKey(testName);
    String? documentUrl = userModel?.medicalDocuments[testName];

    String documentName = "No document";
    if (documentUrl != null) {
      // Extract filename from URL or use default
      try {
        documentName = Uri.parse(documentUrl).pathSegments.last;
      } catch (e) {
        documentName = "Document";
      }
    } else if (hasNewUpload) {
      documentName = uploadedFilesPaths[testName]!.split('/').last;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? Colors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isMandatory ? "$testName *" : testName,
                style: TextStyle(
                  fontWeight: isMandatory ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompleted || hasNewUpload)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Document: $documentName",
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: hasNewUpload
                        ? const Text(
                            "Ready to upload",
                            style: TextStyle(
                                color: Colors.blue,
                                fontStyle: FontStyle.italic),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted)
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () =>
                                viewDocument(testName, documentUrl!),
                            tooltip: "View document",
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: hasNewUpload
                              ? () {
                                  setState(() {
                                    uploadedFilesPaths.remove(testName);
                                  });
                                }
                              : () => removeDocument(testName),
                          tooltip: "Remove document",
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: Text(
                      isCompleted ? "Replace Document" : "Upload Document",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPinkColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => selectFile(testName),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, List<String> options,
      String? selectedValue, IconData icon, ValueChanged<String?> onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: isEditing
          ? DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              hint: Text("Select $title"),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                    value: option, child: Text(option));
              }).toList(),
              onChanged: onChanged,
            )
          : Text(selectedValue ?? "Not provided",
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }

  Widget _buildEditableTile(String title, TextEditingController controller,
      String value, IconData icon,
      {bool isNumeric = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: isEditing
          ? TextFormField(
              controller: controller,
              keyboardType:
                  isNumeric ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                labelText: "Enter $title",
              ),
            )
          : Text(value,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }
}
