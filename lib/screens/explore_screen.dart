import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/auth_service.dart';

import '../services/user_service.dart';

class ExploreScreen extends StatefulWidget {
  final bool isDonor;

  ExploreScreen({super.key, required this.isDonor});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Future<List<UserModel>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = UserService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Welcome To Explore Page",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kRedColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<UserModel>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading users"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            List<UserModel> users = snapshot.data!;

            return GridView.builder(
              itemCount: users.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return _buildUserCard(users[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Blood Type - ${user.bloodType}",
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
                if (user.isDonor) //
                  Text(
                    "Donating Organ- ${user.organType}",
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  )
                else
                  Text(
                    "Organ Needed - ${user.organType}",
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
