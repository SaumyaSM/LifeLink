import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link/models/events_model.dart';

class EventService {
  static const eventsCollection = 'events';

  static Future<List<EventModel>> getEventList() async {
    List<EventModel> list = [];

    await FirebaseFirestore.instance
        .collection(eventsCollection)
        // Filter by date .where()
        .get()
        .then((value) {
      value.docs.forEach((snapshot) {
        list.add(EventModel.fromDocumentSnapshot(snapshot));
      });
    });

    return list;
  }
}
