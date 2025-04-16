// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a match notification
  Future<void> sendMatchNotification(MatchNotification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      print('Error sending notification: $e');
      throw e;
    }
  }

  // Get notifications for a specific user
  Stream<List<MatchNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MatchNotification.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update notification status (accept or reject)
  Future<void> updateNotificationStatus(
      String notificationId, String status) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'status': status});
    } catch (e) {
      print('Error updating notification status: $e');
      throw e;
    }
  }

  // Add this method to the NotificationService class
  Stream<MatchNotification?> getNotificationById(String notificationId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return MatchNotification.fromMap(
          snapshot.data()!,
          snapshot.id,
        );
      }
      return null;
    });
  }
}
