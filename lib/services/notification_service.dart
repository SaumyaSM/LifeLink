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

  Future<void> sendAcceptanceNotification(
      String recipientUserId, String acceptorName, String organType) async {
    try {
      String notificationId = _firestore.collection('notifications').doc().id;

      MatchNotification notification = MatchNotification(
        id: notificationId,
        senderUserId: '',
        senderName: 'System',
        receiverUserId: recipientUserId,
        matchScore: 0,
        matchType: 'acceptance',
        organType: organType,
        status: 'info',
        timestamp: DateTime.now(),
      );

      await sendMatchNotification(notification);
    } catch (e) {
      print('Error sending acceptance notification: $e');
      throw e;
    }
  }

  Future<bool> hasExistingMatchRequest(
      String senderUserId, String receiverUserId) async {
    try {
      // Query for existing notifications between these users
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('notifications')
          .where('senderUserId', isEqualTo: senderUserId)
          .where('receiverUserId', isEqualTo: receiverUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      // If any documents exist, a request is already pending
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing match requests: $e');
      return false;
    }
  }
}
