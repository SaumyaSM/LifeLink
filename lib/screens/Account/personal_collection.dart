import 'package:flutter/material.dart';
import 'package:life_link/models/user_model.dart';
import '../../services/user_service.dart';

class PersonalCollection extends StatefulWidget {
  const PersonalCollection({super.key});

  @override
  State<PersonalCollection> createState() => _PersonalCollectionState();
}

class _PersonalCollectionState extends State<PersonalCollection> {
  UserModel? userModel;
  bool isLoading = true;
  bool isEditing = false;

  // Controllers for editable fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    UserModel? fetchedUser = await UserService.getUserData();
    if (fetchedUser != null) {
      _fullNameController.text = fetchedUser.fullName;
      _dobController.text = fetchedUser.dateOfBirth;
      _genderController.text = fetchedUser.gender;
      _nicController.text = fetchedUser.nic;
      _contactController.text = fetchedUser.contact;
      _addressController.text = fetchedUser.address;
      _cityController.text = fetchedUser.city;
    }
    setState(() {
      userModel = fetchedUser;
      isLoading = false;
    });
  }

  Future<void> saveChanges() async {
    if (userModel != null) {
      UserModel updatedUser = userModel!.copyWith(
        fullName: _fullNameController.text,
        dateOfBirth: _dobController.text,
        gender: _genderController.text,
        nic: _nicController.text,
        contact: _contactController.text,
        address: _addressController.text,
        city: _cityController.text,
      );
      // You can call your update API/service here
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
        title: const Text("User Profile"),
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
                          isEditing
                              ? TextFormField(
                                  controller: _fullNameController,
                                  decoration: const InputDecoration(
                                    labelText: "Full Name",
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                )
                              : _buildInfoTile("Full Name", userModel!.fullName,
                                  Icons.person),
                          const Divider(),
                          _buildEditableTile(
                            "Date of Birth",
                            _dobController,
                            userModel!.dateOfBirth,
                            Icons.calendar_today,
                          ),
                          const Divider(),
                          _buildEditableTile(
                            "Gender",
                            _genderController,
                            userModel!.gender,
                            Icons.male, // or Icons.female depending on gender
                          ),
                          const Divider(),
                          _buildEditableTile(
                            "NIC",
                            _nicController,
                            userModel!.nic,
                            Icons.perm_identity,
                          ),
                          const Divider(),
                          _buildEditableTile(
                            "Contact",
                            _contactController,
                            userModel!.contact,
                            Icons.phone,
                          ),
                          const Divider(),
                          _buildEditableTile(
                            "Address",
                            _addressController,
                            userModel!.address,
                            Icons.location_on,
                          ),
                          const Divider(),
                          _buildEditableTile(
                            "City",
                            _cityController,
                            userModel!.city,
                            Icons.location_city,
                          ),
                          const Divider(),
                          _buildInfoTile(
                            "Role",
                            userModel!.isDonor ? "Donor" : "Recipient",
                            Icons.group,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8.0),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTile(String title, TextEditingController controller,
      String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8.0),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          isEditing
              ? TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Enter $title",
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
        ],
      ),
    );
  }
}
