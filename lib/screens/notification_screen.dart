import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/match_notification_model.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/view_details_screen.dart';
import 'package:life_link/services/notification_service.dart';
import 'package:life_link/services/user_service.dart';

class NotificationsScreen extends StatelessWidget {
  final UserModel currentUser;

  const NotificationsScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kPinkColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<MatchNotification>>(
        stream: NotificationService().getUserNotifications(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Firestore Stream Error: ${snapshot.error}');
            return Center(
              child: Text(
                "Error loading notifications: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, MatchNotification notification) {
    // Determine notification type and status
    final bool isAcceptanceNotification =
        notification.matchType == "acceptance";
    final bool isAdmin = notification.matchType == "admin_approval";
    final bool isPending =
        notification.status == "pending" || notification.status == "liked";
    final bool isAdminApproved = notification.status == "admin_approved";
    final bool isAdminRejected = notification.status == "admin_rejected";
    final bool isMatched = notification.status == "matched";

    // Set colors based on notification status
    Color cardColor;
    IconData statusIcon;
    String statusText;

    if (isAcceptanceNotification) {
      cardColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = "Match Accepted";
    } else if (isAdminApproved) {
      cardColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = "Approved by Medical Team";
    } else if (isAdminRejected) {
      cardColor = Colors.red.shade50;
      statusIcon = Icons.cancel;
      statusText = "Rejected by Medical Team";
    } else if (isMatched) {
      cardColor = Colors.blue.shade50;
      statusIcon = Icons.handshake;
      statusText = "Mutual Match (Pending Review)";
    } else {
      switch (notification.status) {
        case "accepted":
          cardColor = Colors.green.shade50;
          statusIcon = Icons.check_circle;
          statusText = "Accepted";
          break;
        case "rejected":
          cardColor = Colors.red.shade50;
          statusIcon = Icons.cancel;
          statusText = "Declined";
          break;
        case "liked":
          cardColor = Colors.amber.shade50;
          statusIcon = Icons.favorite;
          statusText = "Liked";
          break;
        default:
          cardColor = Colors.amber.shade50;
          statusIcon = Icons.pending;
          statusText = "Pending";
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cardColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cardColor.withOpacity(0.3),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Icon(
                    _getNotificationIcon(notification),
                    color: kPinkColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getNotificationTitle(notification),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _getNotificationDescription(notification),
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (notification.adminFeedback != null &&
                      notification.adminFeedback!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Feedback: ${notification.adminFeedback}",
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (!isAcceptanceNotification &&
                          notification.matchScore > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPinkColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Match Score: ${notification.matchScore}",
                            style: TextStyle(
                              color: kPinkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (!isAcceptanceNotification &&
                          notification.matchScore > 0)
                        const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 12,
                              color: _getStatusColor(notification),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(notification),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Only show View Details for matches that aren't just informational
            if (!isAcceptanceNotification &&
                notification.senderUserId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: ElevatedButton(
                  onPressed: () {
                    // View details of the match
                    _viewMatchDetails(context, notification);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("View Details"),
                ),
              ),
            // Only show action buttons for pending notifications that need action
            if (isPending && !isAcceptanceNotification && !isMatched)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showRejectDialog(context, notification);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Decline"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showAcceptDialog(context, notification);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPinkColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Accept"),
                      ),
                    ),
                  ],
                ),
              ),
            // For matched notifications pending admin review
            if (isMatched && !isAcceptanceNotification)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Waiting for medical team review. They will contact you soon."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Awaiting Medical Review"),
                ),
              ),
            // For acceptance notifications and admin approved matches
            if (isAcceptanceNotification || isAdminApproved)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("The medical team will contact you shortly."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPinkColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Contact Medical Team"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(MatchNotification notification) {
    if (notification.matchType == "acceptance") {
      return Icons.celebration;
    } else if (notification.matchType == "admin_approval") {
      return Icons.admin_panel_settings;
    } else if (notification.status == "matched") {
      return Icons.handshake;
    } else if (notification.status == "admin_approved") {
      return Icons.verified;
    } else if (notification.status == "admin_rejected") {
      return Icons.cancel;
    } else if (notification.senderRole == "donor") {
      return Icons.volunteer_activism;
    } else {
      return Icons.favorite;
    }
  }

  String _getNotificationTitle(MatchNotification notification) {
    if (notification.matchType == "acceptance") {
      return "Match Request Accepted";
    } else if (notification.matchType == "admin_approval") {
      return "Medical Team Review";
    } else if (notification.status == "matched") {
      return "Mutual Match with ${notification.senderName}";
    } else if (notification.status == "admin_approved") {
      return "Match Approved by Medical Team";
    } else if (notification.status == "admin_rejected") {
      return "Match Rejected by Medical Team";
    } else {
      return "Match Request from ${notification.senderName}";
    }
  }

  String _getNotificationDescription(MatchNotification notification) {
    if (notification.matchType == "acceptance") {
      return "Your ${notification.organType} match request has been accepted!";
    } else if (notification.matchType == "admin_approval") {
      return "Your match for ${notification.organType} is being reviewed by the medical team.";
    } else if (notification.status == "matched") {
      return "You and ${notification.senderName} have both liked each other's ${notification.organType} match. The medical team will review your case.";
    } else if (notification.status == "admin_approved") {
      return "Your ${notification.organType} match with ${notification.senderName} has been approved by the medical team.";
    } else if (notification.status == "admin_rejected") {
      return "Your ${notification.organType} match with ${notification.senderName} has been rejected by the medical team.";
    } else if (notification.senderRole == "donor") {
      return "${notification.senderName} would like to donate ${notification.organType} to you";
    } else {
      return "${notification.senderName} would like to receive ${notification.organType} from you";
    }
  }

  Color _getStatusColor(MatchNotification notification) {
    if (notification.matchType == "acceptance" ||
        notification.status == "accepted" ||
        notification.status == "admin_approved") {
      return Colors.green;
    } else if (notification.status == "rejected" ||
        notification.status == "admin_rejected") {
      return Colors.red;
    } else if (notification.status == "matched") {
      return Colors.blue;
    } else {
      return Colors.amber.shade700;
    }
  }

  void _showAcceptDialog(BuildContext context, MatchNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Accept Match Request",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are about to accept the match request from ${notification.senderName}.",
              ),
              const SizedBox(height: 12),
              const Text(
                "If this creates a mutual match, the medical team will be notified for review. Do you want to proceed?",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Check if there's an existing match from the other direction
                  MatchNotification? existingMatch = await NotificationService()
                      .getExistingMatchBetweenUsers(notification.receiverUserId,
                          notification.senderUserId);

                  if (existingMatch != null &&
                      existingMatch.status == "liked") {
                    // This creates a mutual match
                    await NotificationService().createMatchedNotification(
                      notification.id,
                      existingMatch.id,
                    );

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Match accepted! The medical team will review your match soon."),
                        backgroundColor: Colors.blue,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    // Just update this notification to "liked"
                    await NotificationService()
                        .updateNotificationStatus(notification.id, "liked");

                    // Send notification back to the original sender
                    await NotificationService().sendAcceptanceNotification(
                        notification.senderUserId,
                        currentUser.fullName,
                        notification.organType);

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Match accepted! Other Person will be Notified."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error accepting match: $e"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPinkColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, MatchNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Decline Match Request",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are about to decline the match request from ${notification.senderName}.",
              ),
              const SizedBox(height: 12),
              const Text(
                "This action cannot be undone. Do you want to proceed?",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update notification status
                await NotificationService()
                    .updateNotificationStatus(notification.id, "rejected");
                Navigator.of(context).pop();
                // Show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Match request declined."),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Decline"),
            ),
          ],
        );
      },
    );
  }

  void _viewMatchDetails(
      BuildContext context, MatchNotification notification) async {
    // Fetch the sender's user details
    try {
      UserModel sender =
          await UserService.getUserById(notification.senderUserId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewDetailsScreen(
            user: sender,
            currentUser: currentUser,
            matchScore: notification.matchScore,
            isUserDonor:
                notification.senderRole == "recipient", // Updated logic
            isFromNotification: true,
            notificationId: notification.id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not load user details: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
