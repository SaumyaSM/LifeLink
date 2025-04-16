import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import '../models/match_notification_model.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class ViewDetailsScreen extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final int matchScore;
  final bool isUserDonor;

  const ViewDetailsScreen({
    Key? key,
    required this.user,
    required this.currentUser,
    required this.matchScore,
    required this.isUserDonor,
  }) : super(key: key);

  String get matchLevel {
    if (matchScore > 700) return 'Excellent';
    if (matchScore > 500) return 'Good';
    if (matchScore > 300) return 'Moderate';
    return 'Potential';
  }

  Color get matchColor {
    if (matchScore > 700) return Colors.green;
    if (matchScore > 500) return Colors.lightGreen;
    if (matchScore > 300) return Colors.amber;
    return Colors.orange;
  }

  // Format HLA typing map to a readable string
  String formatHlaTyping(Map<String, String> hlaTyping) {
    if (hlaTyping.isEmpty) {
      return "No HLA typing information available";
    }

    return hlaTyping.entries
        .map((entry) => "${entry.key}: ${entry.value}")
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Match Details",
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPinkColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(context),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle("Personal Information"),
                          const SizedBox(height: 12),
                          buildDetailRow(
                              "Full Name", user.fullName, Icons.person),
                          buildDetailRow("Gender", user.gender, Icons.people),
                          buildDetailRow(
                              "City", user.city, Icons.location_city),
                          const Divider(height: 24),
                          buildSectionTitle("Medical Information"),
                          const SizedBox(height: 12),
                          buildDetailRow(
                              "Blood Group", user.bloodType, Icons.bloodtype),
                          buildDetailRow("Organ Type", user.organType,
                              Icons.medical_services),
                          buildExpandableHlaTyping(),
                          const Divider(height: 24),
                          buildSectionTitle("Match Information"),
                          const SizedBox(height: 12),
                          buildMatchScoreDetail(),
                          buildMatchRoleDetail(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      // Select action
                      showConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPinkColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Select This Match",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: kPinkColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 40,
              color: kPinkColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.1),
                  border: Border.all(color: matchColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: matchColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$matchLevel Match",
                      style: TextStyle(
                        color: matchColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Score: $matchScore",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kPinkColor,
      ),
    );
  }

  Widget buildDetailRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPinkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: kPinkColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpandableHlaTyping() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPinkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.science,
              color: kPinkColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "HLA Typing",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 40, top: 4, bottom: 12, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: user.hlaTyping.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      "${entry.key}:",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildMatchScoreDetail() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: matchColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: matchColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: matchColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Match Score: $matchScore",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: matchColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: matchScore / 1000,
              backgroundColor: Colors.grey.shade200,
              color: matchColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This is a $matchLevel match based on blood type compatibility, HLA typing, and other medical factors.",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMatchRoleDetail() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUserDonor ? Colors.blue.shade50 : kPinkColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUserDonor ? Colors.blue.shade200 : kPinkColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUserDonor ? Icons.volunteer_activism : Icons.favorite_border,
            color: isUserDonor ? Colors.blue.shade700 : kPinkColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isUserDonor
                  ? "You will be donating ${currentUser.organType} to ${user.fullName}"
                  : "${user.fullName} will be donating ${user.organType} to you",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isUserDonor ? Colors.blue.shade700 : kPinkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Match Selection",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUserDonor
                    ? "You are about to select ${user.fullName} as your recipient for ${currentUser.organType} donation."
                    : "You are about to select ${user.fullName} as your donor for ${user.organType} donation.",
              ),
              const SizedBox(height: 12),
              const Text(
                "This will notify the medical team and the selected user. They will need to review and accept your selection. Do you want to proceed?",
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
              onPressed: () {
                // Process match selection and send notification
                _sendMatchNotification(context);
                Navigator.of(context).pop();
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Match selection sent! The user will be notified to review your selection."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Navigate back to matches screen
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPinkColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

// This method handles sending the notification to the selected user
  void _sendMatchNotification(BuildContext context) {
    // Create a notification object
    final notification = MatchNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderUserId: currentUser.id,
      senderName: currentUser.fullName,
      receiverUserId: user.id,
      matchScore: matchScore,
      matchType: isUserDonor ? "donation" : "reception",
      organType: isUserDonor ? currentUser.organType : user.organType,
      status: "pending",
      timestamp: DateTime.now(),
    );

    // Add the notification to the database
    NotificationService().sendMatchNotification(notification);
  }
}
