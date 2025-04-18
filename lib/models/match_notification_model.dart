class MatchNotification {
  final String id;
  final String senderUserId;
  final String senderName;
  final String receiverUserId;
  final int matchScore;
  final String
      matchType; // "donation" or "recipient" or "acceptance" or "admin_approval"
  final String organType;
  final String
      status; // "pending", "liked", "matched", "rejected", "admin_approved", "admin_rejected"
  final DateTime timestamp;
  final bool adminReviewed; // Flag to indicate if admin has reviewed this match
  final String? adminFeedback; // Optional feedback from admin

  // Explicit role indicators
  final String senderRole; // "donor" or "recipient"
  final String receiverRole; // "donor" or "recipient"

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
    this.adminReviewed = false,
    this.adminFeedback,
    required this.senderRole,
    required this.receiverRole,
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
      'adminReviewed': adminReviewed,
      'adminFeedback': adminFeedback,
      'senderRole': senderRole,
      'receiverRole': receiverRole,
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
      adminReviewed: map['adminReviewed'] ?? false,
      adminFeedback: map['adminFeedback'],
      senderRole: map['senderRole'],
      receiverRole: map['receiverRole'],
    );
  }

  // Create a copy of this notification with updated fields
  MatchNotification copyWith({
    String? id,
    String? senderUserId,
    String? senderName,
    String? receiverUserId,
    int? matchScore,
    String? matchType,
    String? organType,
    String? status,
    DateTime? timestamp,
    bool? adminReviewed,
    String? adminFeedback,
    String? senderRole,
    String? receiverRole,
  }) {
    return MatchNotification(
      id: id ?? this.id,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      matchScore: matchScore ?? this.matchScore,
      matchType: matchType ?? this.matchType,
      organType: organType ?? this.organType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      adminReviewed: adminReviewed ?? this.adminReviewed,
      adminFeedback: adminFeedback ?? this.adminFeedback,
      senderRole: senderRole ?? this.senderRole,
      receiverRole: receiverRole ?? this.receiverRole,
    );
  }

  // Helper methods to easily identify roles
  bool get isDonorToRecipient =>
      senderRole == 'donor' && receiverRole == 'recipient';
  bool get isRecipientToDonor =>
      senderRole == 'recipient' && receiverRole == 'donor';

  // Helper methods to get donor and recipient regardless of direction
  String get donorUserId =>
      senderRole == 'donor' ? senderUserId : receiverUserId;
  String get recipientUserId =>
      senderRole == 'recipient' ? senderUserId : receiverUserId;
  String get donorName => senderRole == 'donor' ? senderName : 'Unknown';

  // Factory methods for creating common notification types
  static MatchNotification createDonorToRecipientMatch({
    required String id,
    required String donorUserId,
    required String donorName,
    required String recipientUserId,
    required int matchScore,
    required String organType,
    String status = 'pending',
    required DateTime timestamp,
  }) {
    return MatchNotification(
      id: id,
      senderUserId: donorUserId,
      senderName: donorName,
      receiverUserId: recipientUserId,
      matchScore: matchScore,
      matchType: 'donation',
      organType: organType,
      status: status,
      timestamp: timestamp,
      senderRole: 'donor',
      receiverRole: 'recipient',
    );
  }

  static MatchNotification createRecipientToDonorMatch({
    required String id,
    required String recipientUserId,
    required String recipientName,
    required String donorUserId,
    required int matchScore,
    required String organType,
    String status = 'pending',
    required DateTime timestamp,
  }) {
    return MatchNotification(
      id: id,
      senderUserId: recipientUserId,
      senderName: recipientName,
      receiverUserId: donorUserId,
      matchScore: matchScore,
      matchType: 'recipient',
      organType: organType,
      status: status,
      timestamp: timestamp,
      senderRole: 'recipient',
      receiverRole: 'donor',
    );
  }
}
