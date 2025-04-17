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
            print(
                'Firestore Stream Error: ${snapshot.error}'); // This will print in your terminal

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
    // Determine if this notification is still pending action
    final bool isPending = notification.status == "pending";

    // Check if this is an acceptance notification
    final bool isAcceptanceNotification =
        notification.matchType == "acceptance";

    // Set colors based on notification status
    Color cardColor;
    IconData statusIcon;
    String statusText;

    if (isAcceptanceNotification) {
      cardColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = "Match Accepted";
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
        default:
          cardColor = Colors.amber.shade50;
          statusIcon = Icons.pending;
          statusText = "Pending Review";
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
                    isAcceptanceNotification
                        ? Icons.celebration
                        : notification.matchType == "donation"
                            ? Icons.volunteer_activism
                            : Icons.favorite,
                    color: kPinkColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAcceptanceNotification
                          ? "Match Request Accepted"
                          : "Match Request from ${notification.senderName}",
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
                    isAcceptanceNotification
                        ? "Your ${notification.organType} match request has been accepted!"
                        : notification.matchType == "donation"
                            ? "${notification.senderName} would like to donate ${notification.organType} to you"
                            : "${notification.senderName} would like to receive ${notification.organType} from you",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (!isAcceptanceNotification)
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
                      if (!isAcceptanceNotification) const SizedBox(width: 8),
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
                              color: isAcceptanceNotification
                                  ? Colors.green
                                  : notification.status == "pending"
                                      ? Colors.amber.shade700
                                      : notification.status == "accepted"
                                          ? Colors.green
                                          : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAcceptanceNotification
                                    ? Colors.green
                                    : notification.status == "pending"
                                        ? Colors.amber.shade700
                                        : notification.status == "accepted"
                                            ? Colors.green
                                            : Colors.red,
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
            // Only show View Details for regular match notifications, not for acceptance notifications
            if (!isAcceptanceNotification)
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
            // Only show action buttons for pending notifications that are not acceptance notifications
            if (isPending && !isAcceptanceNotification)
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
            // For acceptance notifications, show a Contact button
            if (isAcceptanceNotification)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  onPressed: () {
                    // This could navigate to a contact details screen or show contact info
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
                "The medical team will be notified about this match. Do you want to proceed?",
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
                    .updateNotificationStatus(notification.id, "accepted");

                // Send notification back to the original sender
                await NotificationService().sendAcceptanceNotification(
                    notification.senderUserId,
                    currentUser.fullName,
                    notification.organType);

                Navigator.of(context).pop();
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Match accepted! The medical team will be in touch soon."),
                    backgroundColor: Colors.green,
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
            isUserDonor: notification.matchType == "reception",
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
