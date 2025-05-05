import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:path/path.dart' as path;

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
      // First, check if the user is authenticated
      String? currentUserId = AuthService.getLoggedUserID();
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception("User not authenticated");
      }

      // Ensure userId matches the current authenticated user
      if (userId != currentUserId) {
        throw Exception(
            "Unauthorized: Cannot upload documents for another user");
      }

      for (var entry in filePaths.entries) {
        String testName = entry.key;
        String filePath = entry.value;

        // Verify file exists before attempting upload
        File file = File(filePath);
        if (!file.existsSync()) {
          print("Warning: File does not exist at path: $filePath");
          continue; // Skip this file and continue with others
        }

        // Create a more sanitized filename
        String sanitizedTestName = testName
            .replaceAll(' ', '_')
            .replaceAll('\n', '_')
            .replaceAll('(', '')
            .replaceAll(')', '')
            .replaceAll('-', '_')
            .replaceAll('&', 'and');

        // Detect file type from content
        String fileExtension = '';
        String contentType = '';

        try {
          List<int> bytes = await file.openRead(0, 8).first;

          // Check for PDF signature (%PDF)
          if (bytes.length >= 4 &&
              bytes[0] == 0x25 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x44 &&
              bytes[3] == 0x46) {
            fileExtension = '.pdf';
            contentType = 'application/pdf';
          }
          // Check for JPEG signature
          else if (bytes.length >= 3 &&
              bytes[0] == 0xFF &&
              bytes[1] == 0xD8 &&
              bytes[2] == 0xFF) {
            fileExtension = '.jpg';
            contentType = 'image/jpeg';
          }
          // Check for PNG signature
          else if (bytes.length >= 8 &&
              bytes[0] == 0x89 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x4E &&
              bytes[3] == 0x47 &&
              bytes[4] == 0x0D &&
              bytes[5] == 0x0A &&
              bytes[6] == 0x1A &&
              bytes[7] == 0x0A) {
            fileExtension = '.png';
            contentType = 'image/png';
          }
          // If detection fails, fall back to extension
          else {
            fileExtension = path.extension(filePath).toLowerCase();
            if (fileExtension == '.pdf') {
              contentType = 'application/pdf';
            } else if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
              contentType = 'image/jpeg';
            } else if (fileExtension == '.png') {
              contentType = 'image/png';
            } else {
              // Default to octet-stream for unknown types
              contentType = 'application/octet-stream';
              fileExtension = fileExtension.isEmpty ? '.bin' : fileExtension;
            }
          }
        } catch (e) {
          print("Error detecting file type: $e");
          // Fallback to extension
          fileExtension = path.extension(filePath).toLowerCase();
          if (fileExtension.isEmpty) fileExtension = '.pdf';
          contentType = fileExtension == '.pdf'
              ? 'application/pdf'
              : (fileExtension == '.jpg' || fileExtension == '.jpeg')
                  ? 'image/jpeg'
                  : fileExtension == '.png'
                      ? 'image/png'
                      : 'application/octet-stream';
        }

        String fileName =
            "${userId}_${sanitizedTestName}_${DateTime.now().millisecondsSinceEpoch}$fileExtension";

        // Create reference with proper path structure
        Reference storageRef = _storage
            .ref()
            .child("medical_documents")
            .child(userId)
            .child(fileName);

        // Set metadata with the detected content type
        SettableMetadata metadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'userId': userId,
            'testName': testName,
            'actualFileType': contentType // Add this to help with debugging
          },
        );

        // Upload with metadata and error handling
        try {
          UploadTask uploadTask = storageRef.putFile(file, metadata);

          // Monitor progress (optional)
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print(
                'Upload progress for $testName: ${(progress * 100).toStringAsFixed(2)}%');
          }, onError: (e) {
            print('Error during upload of $testName: $e');
          });

          // Wait for completion
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          firebaseUrls[testName] = downloadUrl;
          print(
              'Successfully uploaded $testName as $contentType: $downloadUrl');
        } catch (uploadError) {
          print('Error uploading $testName: $uploadError');
          // Continue with other files even if one fails
        }
      }

      // Update user document with new URLs
      if (firebaseUrls.isNotEmpty) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection(userCollection)
            .doc(userId)
            .get();

        if (userSnapshot.exists) {
          UserModel user = UserModel.fromDocumentSnapshot(userSnapshot);

          // Merge existing and new document URLs
          Map<String, String> updatedMedicalDocuments = {
            ...user.medicalDocuments
          };
          updatedMedicalDocuments.addAll(firebaseUrls);

          // Update user model
          await updateUserData(user.copyWith(
            medicalDocuments: updatedMedicalDocuments,
          ));
        }
      }

      return firebaseUrls;
    } catch (e) {
      print("Error in uploadMedicalDocuments: $e");
      throw e; // Re-throw to be handled by the UI
    }
  }

  static Future<void> removeMedicalDocument(
      String userId, String testName) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      // First, check if the user is authenticated
      String? currentUserId = AuthService.getLoggedUserID();
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception("User not authenticated");
      }

      // Ensure userId matches the current authenticated user
      if (userId != currentUserId) {
        throw Exception(
            "Unauthorized: Cannot remove documents for another user");
      }

      // Get user document to find the document URL
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        throw Exception("User data not found");
      }

      // Create user model from document
      UserModel user = UserModel.fromDocumentSnapshot(userSnapshot);

      // Check if the document exists in user's medicalDocuments
      if (!user.medicalDocuments.containsKey(testName)) {
        throw Exception("Document for test '$testName' not found");
      }

      // Get the document URL
      String documentUrl = user.medicalDocuments[testName]!;

      // Delete from Firebase Storage
      try {
        // Extract file reference from the URL
        // The URL format would be something like:
        // https://firebasestorage.googleapis.com/v0/b/[bucket]/o/medical_documents%2F[userId]%2F[fileName]?alt=media...

        Uri uri = Uri.parse(documentUrl);
        String path = Uri.decodeComponent(uri.path);

        // Extract the path after /o/ which is the file path in Firebase Storage
        int startIndex = path.indexOf('/o/') + 3;
        String storagePath = path.substring(startIndex);

        // If there's a query parameter, remove it
        if (storagePath.contains('?')) {
          storagePath = storagePath.substring(0, storagePath.indexOf('?'));
        }

        // Create reference to the file
        Reference fileRef = _storage.ref().child(storagePath);

        // Delete the file
        await fileRef.delete();

        // Update user document to remove the reference
        Map<String, String> updatedMedicalDocuments = {
          ...user.medicalDocuments
        };
        updatedMedicalDocuments.remove(testName);

        // Update user model in Firestore
        await updateUserData(user.copyWith(
          medicalDocuments: updatedMedicalDocuments,
        ));

        print('Successfully removed document for test: $testName');
      } catch (e) {
        print('Error removing file from storage: $e');
        throw Exception("Error removing file from storage: $e");
      }
    } catch (e) {
      print("Error in removeMedicalDocument: $e");
      throw e; // Re-throw to be handled by the UI
    }
  }

  static Future<void> updateTestCompletionStatus(
      String userId, bool isCompleted) async {
    try {
      String? currentUserId = AuthService.getLoggedUserID();
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception("User not authenticated");
      }

      // Ensure userId matches the current authenticated user
      if (userId != currentUserId) {
        throw Exception("Unauthorized: Cannot update status for another user");
      }

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
