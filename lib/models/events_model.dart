import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  late String title;
  late String date;
  late String description;

  EventModel({
    required this.date,
    required this.description,
    required this.title,
  });

  EventModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    title = documentSnapshot['title'] ?? '';
    description = documentSnapshot['description'] ?? '';
    title = documentSnapshot['title'] ?? '';
  }
}
