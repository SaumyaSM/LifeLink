import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? documentID;
  late String id;
  late String fullName;
  late String dateOfBirth;
  late String gender;
  late String nic;
  late String contact;
  late String address;
  late bool isDonor;
  late String bloodType;
  late String organType;
  late String medicalConditions;
  late String medications;
  late String allergies;
  late List<String> medicalReports;
  late bool isTestsCompleted;

  UserModel({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.nic,
    required this.contact,
    required this.address,
    required this.isDonor,
    required this.bloodType,
    required this.organType,
    required this.medicalConditions,
    required this.medications,
    required this.allergies,
    required this.medicalReports,
    required this.isTestsCompleted,
  });

  UserModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    documentID = documentSnapshot.id;
    id = documentSnapshot.id;
    fullName = documentSnapshot['fullName'] ?? '';
    dateOfBirth = documentSnapshot['dateOfBirth'] ?? '';
    gender = documentSnapshot['gender'] ?? '';
    nic = documentSnapshot['nic'] ?? '';
    contact = documentSnapshot['contact'] ?? '';
    address = documentSnapshot['address'] ?? '';
    isDonor = documentSnapshot['isDonor'] ?? false;
    bloodType = documentSnapshot['bloodType'] ?? '';
    organType = documentSnapshot['organType'] ?? '';
    medicalConditions = documentSnapshot['medicalConditions'] ?? '';
    medications = documentSnapshot['medications'] ?? '';
    allergies = documentSnapshot['allergies'] ?? '';
    medicalReports =
        List<String>.from(documentSnapshot['medicalReports'] ?? []);
    isTestsCompleted = documentSnapshot['isTestsCompleted'] ?? false;
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nic': nic,
      'contact': contact,
      'address': address,
      'isDonor': isDonor,
      'bloodType': bloodType,
      'organType': organType,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'allergies': allergies,
      'medicalReports': medicalReports,
      'isTestsCompleted': isTestsCompleted,
    };
  }
}
