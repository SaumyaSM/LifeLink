import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/user_service.dart';

class MedicalCollection extends StatefulWidget {
  const MedicalCollection({super.key});

  @override
  State<MedicalCollection> createState() => _MedicalCollectionState();
}

class _MedicalCollectionState extends State<MedicalCollection> {
  UserModel? userModel;
  bool isLoading = true;
  bool isEditing = false;

  // Controllers for editable fields
  final _hlaAController = TextEditingController();
  final _hlaBController = TextEditingController();
  final _hlaCController = TextEditingController();
  final _hlaDRB1Controller = TextEditingController();
  final _hlaDQB1Controller = TextEditingController();
  final _waitingTimeController = TextEditingController();

  String? selectedOrganType;
  String? selectedBloodType;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPinkColor,
        title: const Text("Medical Info"),
        actions: [
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
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
                              "Waiting Time (Years)",
                              _waitingTimeController,
                              userModel!.waitingTime.toString(),
                              Icons.hourglass_bottom,
                              isNumeric: true,
                            ),
                        ],
                      ),
                    ),
                  ),
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
