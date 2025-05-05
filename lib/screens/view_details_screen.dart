import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import '../models/match_notification_model.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';

class ViewDetailsScreen extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;
  final int matchScore;
  final bool isUserDonor;
  final bool isFromNotification; // New parameter to track the source
  final String? notificationId; // Optional notification ID for action tracking

  const ViewDetailsScreen({
    Key? key,
    required this.user,
    required this.currentUser,
    required this.matchScore,
    required this.isUserDonor,
    this.isFromNotification =
        false, // Default to false for backward compatibility
    this.notificationId,
  }) : super(key: key);

  @override
  State<ViewDetailsScreen> createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  String? _imageURL;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      String? imageUrl = await UserService().fetchProfileImage(widget.user.id);
      if (imageUrl != null && mounted) {
        setState(() {
          _imageURL = imageUrl;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile image: $e");
    }
  }

  String get matchLevel {
    if (widget.matchScore > 700) return 'Excellent';
    if (widget.matchScore > 500) return 'Good';
    if (widget.matchScore > 300) return 'Moderate';
    return 'Potential';
  }

  Color get matchColor {
    if (widget.matchScore > 700) return Colors.green;
    if (widget.matchScore > 500) return Colors.lightGreen;
    if (widget.matchScore > 300) return Colors.amber;
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
        title: Text(
          widget.isFromNotification ? "Match Details" : "Select Match",
          style: const TextStyle(
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
                              "Full Name", widget.user.fullName, Icons.person),
                          buildDetailRow(
                              "Gender", widget.user.gender, Icons.people),
                          buildDetailRow(
                              "City", widget.user.city, Icons.location_city),
                          const Divider(height: 24),
                          buildSectionTitle("Medical Information"),
                          const SizedBox(height: 12),
                          buildDetailRow("Blood Group", widget.user.bloodType,
                              Icons.bloodtype),
                          buildDetailRow("Organ Type", widget.user.organType,
                              Icons.medical_services),
                          buildExpandableHlaTyping(),
                          const Divider(height: 24),
                          buildSectionTitle("Match Information"),
                          const SizedBox(height: 12),
                          buildMatchScoreDetail(),
                          buildMatchRoleDetail(),

                          // Show notification status if coming from notification
                          if (widget.isFromNotification &&
                              widget.notificationId != null)
                            buildNotificationStatus(context),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Only show the action button if not viewing from notification
                if (!widget.isFromNotification)
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

                // Add contact info section when viewing from notifications
                if (widget.isFromNotification) buildContactInfoSection(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated notification status to work with the new model
  Widget buildNotificationStatus(BuildContext context) {
    return StreamBuilder<MatchNotification?>(
      stream: NotificationService().getNotificationById(widget.notificationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final notification = snapshot.data!;

        // Status information container
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getStatusColor(notification.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color:
                        getStatusColor(notification.status).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        getStatusIcon(notification.status),
                        color: getStatusColor(notification.status),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Current Status: ${getStatusText(notification.status)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(notification.status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getStatusDescription(notification.status),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),

                  // Add role information based on the updated model
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          notification.isDonorToRecipient
                              ? Icons.volunteer_activism
                              : Icons.favorite_border,
                          color: notification.isDonorToRecipient
                              ? Colors.blue.shade700
                              : kPinkColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.isDonorToRecipient
                                ? "Donor to Recipient"
                                : "Recipient to Donor",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: notification.isDonorToRecipient
                                  ? Colors.blue.shade700
                                  : kPinkColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Add admin review section if the notification has been reviewed
            if (notification.adminReviewed)
              buildAdminReviewSection(notification),
          ],
        );
      },
    );
  }

  // New method to build admin review section
  Widget buildAdminReviewSection(MatchNotification notification) {
    final bool isApproved = notification.status == "admin_approved";

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isApproved
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproved
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApproved ? Icons.check_circle : Icons.cancel,
                color: isApproved ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Medical Team Review",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isApproved ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (notification.adminFeedback != null &&
              notification.adminFeedback!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Feedback:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.adminFeedback!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for notification status
  Color getStatusColor(String status) {
    switch (status) {
      case "liked":
      case "matched":
      case "accepted":
      case "admin_approved":
        return Colors.green;
      case "rejected":
      case "admin_rejected":
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "liked":
      case "matched":
      case "accepted":
      case "admin_approved":
        return Icons.check_circle;
      case "rejected":
      case "admin_rejected":
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case "liked":
        return "Liked";
      case "matched":
        return "Matched";
      case "accepted":
        return "Accepted";
      case "rejected":
        return "Declined";
      case "admin_approved":
        return "Approved by\nMedical Team";
      case "admin_rejected":
        return "Declined by\nMedical Team";
      default:
        return "Pending Review";
    }
  }

  String getStatusDescription(String status) {
    switch (status) {
      case "liked":
        return "This match has been liked. Waiting for confirmation from both parties.";
      case "matched":
        return "This match has been confirmed by both parties. The medical team will review this match.";
      case "accepted":
        return "This match has been accepted. The medical team will review this match before proceeding.";
      case "rejected":
        return "This match was declined. You may consider other potential matches.";
      case "admin_approved":
        return "This match has been reviewed and approved by the medical team. The next steps in the transplant process can begin.";
      case "admin_rejected":
        return "The medical team has reviewed this match and found it unsuitable. Please see their feedback below.";
      default:
        return "This match is awaiting a response. You'll be notified once a decision is made.";
    }
  }

  // New method to build contact info section
  Widget buildContactInfoSection(BuildContext context) {
    return Padding(
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
              buildSectionTitle("Medical Team Contact"),
              const SizedBox(height: 12),
              const Text(
                "If you have any questions about this match or need assistance, please contact our medical team:",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              buildContactItem(
                Icons.local_hospital,
                "Transplant Coordinator",
                "Dr. Sarah Johnson",
                "+1 (555) 123-4567",
              ),
              const SizedBox(height: 8),
              buildContactItem(
                Icons.email,
                "Medical Support Email",
                "support@lifelink.org",
                "",
              ),
              const SizedBox(height: 8),
              buildContactItem(
                Icons.info_outline,
                "Patient Support Line",
                "Available 24/7",
                "+1 (800) 555-0123",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContactItem(
      IconData icon, String title, String name, String contact) {
    return Row(
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
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (contact.isNotEmpty)
                Text(
                  contact,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        ),
      ],
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
          _imageURL != null && _imageURL!.isNotEmpty
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(_imageURL!),
                  backgroundColor: kPinkColor.withOpacity(0.1),
                )
              : CircleAvatar(
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
            widget.user.fullName,
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
                  "Score: ${widget.matchScore}",
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
            children: widget.user.hlaTyping.entries.map((entry) {
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
                "Match Score: ${widget.matchScore}",
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
              value: widget.matchScore / 1000,
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
        color: widget.isUserDonor
            ? Colors.blue.shade50
            : kPinkColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isUserDonor
              ? Colors.blue.shade200
              : kPinkColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.isUserDonor
                ? Icons.volunteer_activism
                : Icons.favorite_border,
            color: widget.isUserDonor ? Colors.blue.shade700 : kPinkColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isUserDonor
                  ? "You will be donating ${widget.currentUser.organType} to ${widget.user.fullName}"
                  : "${widget.user.fullName} will be donating ${widget.user.organType} to you",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: widget.isUserDonor ? Colors.blue.shade700 : kPinkColor,
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
      builder: (BuildContext dialogContext) {
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
                widget.isUserDonor
                    ? "You are about to select ${widget.user.fullName} as your recipient for ${widget.currentUser.organType} donation."
                    : "You are about to select ${widget.user.fullName} as your donor for ${widget.user.organType} donation.",
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
                Navigator.of(dialogContext).pop();
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
                // Close the dialog first
                Navigator.of(dialogContext).pop();

                // Then send notification and handle navigation
                _sendMatchNotificationAndNavigate(context);
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

  Future<void> _sendMatchNotificationAndNavigate(BuildContext context) async {
    bool hasSentRequest = await NotificationService()
        .hasExistingMatchRequest(widget.currentUser.id, widget.user.id);
    bool hasReceivedRequest = await NotificationService()
        .hasExistingMatchRequest(widget.user.id, widget.currentUser.id);

    bool isUserAlreadyMatched =
        await NotificationService().isUserAlreadyMatched(widget.user.id);

    if (isUserAlreadyMatched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${widget.user.fullName} is already matched with another person. Please select someone else.",
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    bool isCurrentUserAlreadyMatched =
        await NotificationService().isUserAlreadyMatched(widget.currentUser.id);

    if (isCurrentUserAlreadyMatched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You are already matched with another person. You cannot initiate new matches.",
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (hasSentRequest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "You've already sent a match request to this person. Please wait for their response.",
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (hasReceivedRequest) {
      MatchNotification? existingNotification = await NotificationService()
          .getExistingMatchRequestNotification(
              widget.user.id, widget.currentUser.id);

      if (existingNotification != null) {
        // Show different message and navigate to notifications
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "You already have a pending request from ${widget.user.fullName}. Please respond to it in your notifications.",
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VIEW',
              onPressed: () {
                // Navigate to notifications screen
                Navigator.pop(context);
                // Navigator.pushNamed(context, '/notifications');
              },
            ),
          ),
        );
        return;
      }
    }
  }
}
