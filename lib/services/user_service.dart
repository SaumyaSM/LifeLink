import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/auth_service.dart';

import 'organ_matching_service.dart';

class UserService {
  static final userCollection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createUser(UserModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }

  static Future<void> updateUserData(UserModel user) async {
    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user.id)
        .update(user.toMap());
  }

  static Future<UserModel> getUserData() async {
    return UserModel.fromDocumentSnapshot(
      await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(AuthService.getLoggedUserID())
          .get(),
    );
  }

  static Future<UserModel> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(userId)
        .get();

    if (!doc.exists) {
      throw Exception("User not found");
    }

    return UserModel.fromDocumentSnapshot(doc);
  }

  static Future<List<UserModel>> getDonors() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDonor', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromDocumentSnapshot(doc))
        .toList();
  }

  static Future<List<UserModel>> getRecipients() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDonor', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromDocumentSnapshot(doc))
        .toList();
  }

  static Future<List<UserModel>> fetchUsers() async {
    String? currentUserId = AuthService.getLoggedUserID();
    if (currentUserId == null) return [];

    Map<String, List<String>> bloodCompatibility = {
      'O': ['O', 'A', 'B', 'AB'],
      'A': ['A', 'AB'],
      'B': ['B', 'AB'],
      'AB': ['AB'],
    };

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(currentUserId)
        .get();

    if (!userSnapshot.exists) return [];

    UserModel currentUserData = UserModel.fromDocumentSnapshot(userSnapshot);

    List<String> compatibleBloodTypes =
        bloodCompatibility[currentUserData.bloodType] ?? [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(userCollection)
        .where('isDonor', isEqualTo: !currentUserData.isDonor)
        .where('bloodType',
            whereIn: compatibleBloodTypes) // <-- Blood compatibility logic
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<String?> fetchProfileImage(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return userDoc['profileImageUrl'] as String?;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(
      String userId, File imageFile, BuildContext context) async {
    String fileName = "profile_$userId.jpg";
    Reference storageRef =
        FirebaseStorage.instance.ref().child("profile_images").child(fileName);

    try {
      print("Uploading image for user ID: $userId");
      print("File path: ${imageFile.path}");

      if (!imageFile.existsSync()) {
        print("Error: File does not exist.");
        return null;
      }

      UploadTask uploadTask = storageRef.putFile(imageFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            "Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}");
      }, onError: (e) {
        print("Error during upload: $e");
      });

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      print("Upload successful! Image URL: $imageUrl");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImageUrl': imageUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile picture updated successfully!")),
      );

      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
      return null;
    }
  }

  /// Fetches matches for the current logged-in user
  static Future<List<Map<String, dynamic>>> fetchUserMatches() async {
    final String currentUserId = AuthService.getLoggedUserID();

    List<Map<String, dynamic>> matchedPairs =
        await MatchingService.matchDonorsAndRecipients();

    List<Map<String, dynamic>> userMatches = matchedPairs.where((match) {
      UserModel donor = match['donor'];
      UserModel recipient = match['recipient'];

      return donor.id == currentUserId || recipient.id == currentUserId;
    }).toList();

    return userMatches;
  }

  static Future<Map<String, String>> uploadMedicalDocuments(
      String userId, Map<String, String> filePaths) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    Map<String, String> firebaseUrls = {};

    try {
      for (var entry in filePaths.entries) {
        String testName = entry.key;
        String filePath = entry.value;

        String fileName =
            "${userId}_${testName.replaceAll(' ', '_').replaceAll('\n', '_')}.pdf";
        Reference storageRef = _storage
            .ref()
            .child("medical_documents")
            .child(userId)
            .child(fileName);

        File file = File(filePath);
        UploadTask uploadTask = storageRef.putFile(file);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        firebaseUrls[testName] = downloadUrl;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        UserModel user = UserModel.fromDocumentSnapshot(userSnapshot);

        Map<String, String> updatedMedicalDocuments = {
          ...user.medicalDocuments
        };
        updatedMedicalDocuments.addAll(firebaseUrls);

        UserModel updatedUser = user.copyWith(
          medicalDocuments: updatedMedicalDocuments,
        );

        await updateUserData(updatedUser);
      }

      return firebaseUrls;
    } catch (e) {
      print("Error uploading medical documents: $e");
      throw e;
    }
  }

  static Future<void> updateTestCompletionStatus(
      String userId, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(userId)
          .update({'isTestsCompleted': isCompleted});
    } catch (e) {
      print("Error updating test completion status: $e");
      throw e;
    }
  }
}
