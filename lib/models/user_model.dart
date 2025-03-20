import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String id;
  late String fullName;
  late String dateOfBirth;
  late String gender;
  late String nic;
  late String contact;
  late String address;
  late String city;
  late bool isDonor;
  late String bloodType;
  late String organType;
  late Map<String, String> hlaTyping;
  late String medicalConditions;
  late String medications;
  late String allergies;
  late List<String> medicalReports;
  late bool isTestsCompleted;
  late List<String> likes;
  late List<String> history;

  UserModel({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.nic,
    required this.contact,
    required this.address,
    required this.city,
    required this.isDonor,
    required this.bloodType,
    required this.organType,
    required this.hlaTyping,
    required this.medicalConditions,
    required this.medications,
    required this.allergies,
    required this.medicalReports,
    required this.isTestsCompleted,
    required this.likes,
    required this.history,
  });

  UserModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot['id'];
    fullName = documentSnapshot['fullName'] ?? '';
    dateOfBirth = documentSnapshot['dateOfBirth'] ?? '';
    gender = documentSnapshot['gender'] ?? '';
    nic = documentSnapshot['nic'] ?? '';
    contact = documentSnapshot['contact'] ?? '';
    address = documentSnapshot['address'] ?? '';
    city = documentSnapshot['city'] ?? '';
    isDonor = documentSnapshot['isDonor'] ?? false;
    bloodType = documentSnapshot['bloodType'] ?? '';
    organType = documentSnapshot['organType'] ?? '';
    hlaTyping = documentSnapshot['hlaTyping'] ?? '';
    medicalConditions = documentSnapshot['medicalConditions'] ?? '';
    medications = documentSnapshot['medications'] ?? '';
    allergies = documentSnapshot['allergies'] ?? '';
    medicalReports =
        List<String>.from(documentSnapshot['medicalReports'] ?? []);
    isTestsCompleted = documentSnapshot['isTestsCompleted'] ?? false;
    likes = List<String>.from(documentSnapshot['likes'] ?? []);
    history = List<String>.from(documentSnapshot['history'] ?? []);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nic': nic,
      'contact': contact,
      'address': address,
      'city': city,
      'isDonor': isDonor,
      'bloodType': bloodType,
      'organType': organType,
      'hlaTyping': hlaTyping,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'allergies': allergies,
      'medicalReports': medicalReports,
      'isTestsCompleted': isTestsCompleted,
      'likes': likes,
      'history': history,
    };
  }
}

extension UserModelCopy on UserModel {
  UserModel copyWith({
    String? id,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? nic,
    String? contact,
    String? address,
    String? city,
    bool? isDonor,
    String? bloodType,
    String? organType,
    Map<String, String>? hlaTyping,
    String? medicalConditions,
    String? medications,
    String? allergies,
    List<String>? medicalReports,
    bool? isTestsCompleted,
    List<String>? likes,
    List<String>? history,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nic: nic ?? this.nic,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      city: city ?? this.city,
      isDonor: isDonor ?? this.isDonor,
      bloodType: bloodType ?? this.bloodType,
      organType: organType ?? this.organType,
      hlaTyping: hlaTyping ?? this.hlaTyping,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      medicalReports: medicalReports ?? this.medicalReports,
      isTestsCompleted: isTestsCompleted ?? this.isTestsCompleted,
      likes: likes ?? this.likes,
      history: history ?? this.history,
    );
  }
}
