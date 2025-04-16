// lib/models/match_notification_model.dart
class MatchNotification {
  final String id;
  final String senderUserId;
  final String senderName;
  final String receiverUserId;
  final int matchScore;
  final String matchType; // "donation" or "reception"
  final String organType;
  final String status; // "pending", "accepted", "rejected"
  final DateTime timestamp;

  MatchNotification({
    required this.id,
    required this.senderUserId,
    required this.senderName,
    required this.receiverUserId,
    required this.matchScore,
    required this.matchType,
    required this.organType,
    required this.status,
    required this.timestamp,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderUserId': senderUserId,
      'senderName': senderName,
      'receiverUserId': receiverUserId,
      'matchScore': matchScore,
      'matchType': matchType,
      'organType': organType,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Map (from Firebase)
  factory MatchNotification.fromMap(Map<String, dynamic> map, String id) {
    return MatchNotification(
      id: id, // use the passed-in ID from the doc
      senderUserId: map['senderUserId'],
      senderName: map['senderName'],
      receiverUserId: map['receiverUserId'],
      matchScore: map['matchScore'],
      matchType: map['matchType'],
      organType: map['organType'],
      status: map['status'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
