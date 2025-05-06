import 'package:flutter/material.dart';
import '../../models/donation_status_model.dart';
import '../../services/auth_service.dart';
import '../../services/donation_status_service.dart';
import '../../services/user_service.dart'; // Add this import for user service

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({Key? key}) : super(key: key);

  @override
  _DonationHistoryScreenState createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  final DonationStatusService _donationStatusService = DonationStatusService();
  final UserService _userService = UserService(); // Add user service
  String? _currentUserId;
  bool _isLoading = true;
  List<DonationStatus> _completedDonations = [];
  bool _isDonor = true; // Track if user is donor or recipient

  @override
  void initState() {
    super.initState();
    _loadUserAndDonationHistory();
  }

  Future<void> _loadUserAndDonationHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      _currentUserId = await AuthService.getCurrentUserId();
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // First get the user to determine if they're a donor or recipient
      final user = await UserService.getUserById(_currentUserId!);
      if (user != null) {
        _isDonor = user.isDonor;
      }

      // Get all donation statuses for the current user
      List<DonationStatus> userStatuses = await _donationStatusService
          .getUserDonationStatusesFuture(_currentUserId!);

      // Filter for completed donations (those that have reached follow-up care)
      // AND filter for the appropriate role (donor or recipient)
      _completedDonations = userStatuses
          .where((status) =>
              status.status == DonationStatusType.followUpCare &&
              (_isDonor
                  ? status.donorId == _currentUserId
                  : status.recipientId == _currentUserId))
          .toList();

      // Sort by most recent first
      _completedDonations
          .sort((a, b) => b.statusTimestamp.compareTo(a.statusTimestamp));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading donation history: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isDonor ? 'Donation History' : 'Transplant History'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserAndDonationHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _completedDonations.isEmpty
                    ? _buildEmptyState()
                    : _buildDonationHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 56,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _isDonor ? 'No Donation History' : 'No Transplant History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _isDonor
                  ? 'You have not completed any donations yet'
                  : 'You have not received any transplants yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserAndDonationHistory,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: _completedDonations.length,
      itemBuilder: (context, index) {
        final donation = _completedDonations[index];
        return _buildDonationHistoryCard(donation);
      },
    );
  }

  Widget _buildDonationHistoryCard(DonationStatus donation) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final completionDate =
        donation.statusHistory['followUpCare'] ?? donation.statusTimestamp;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DonationHistoryDetailScreen(donationId: donation.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _isDonor ? '❤️' : '🫀',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDonor
                              ? 'Donated ${donation.organType}'
                              : 'Received ${donation.organType}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isDonor
                              ? 'To: ${donation.recipientName}'
                              : 'From: ${donation.donorName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(completionDate),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationHistoryDetailScreen(
                              donationId: donation.id),
                        ),
                      );
                    },
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Keep the DonationHistoryDetailScreen the same as it already determines
// if the user is a donor or recipient for the specific donation
class DonationHistoryDetailScreen extends StatefulWidget {
  final String donationId;

  const DonationHistoryDetailScreen({Key? key, required this.donationId})
      : super(key: key);

  @override
  _DonationHistoryDetailScreenState createState() =>
      _DonationHistoryDetailScreenState();
}

class _DonationHistoryDetailScreenState
    extends State<DonationHistoryDetailScreen> {
  final DonationStatusService _donationStatusService = DonationStatusService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  DonationStatus? _donationStatus;
  String? _currentUserId;
  bool _isDonor = false;

  @override
  void initState() {
    super.initState();
    _loadDonationDetails();
  }

  Future<void> _loadDonationDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      _currentUserId = await AuthService.getCurrentUserId();
      _donationStatus =
          await _donationStatusService.getDonationStatus(widget.donationId);

      if (_donationStatus != null && _currentUserId != null) {
        _isDonor = _donationStatus!.donorId == _currentUserId;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading donation details: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donationStatus == null
              ? Center(child: Text('Donation not found'))
              : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final statusInfo = _donationStatus!.getStatusInfo();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    radius: 40,
                    child: Text(
                      _isDonor ? '❤️' : '🫀',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isDonor
                        ? 'You donated ${_donationStatus!.organType.toLowerCase()}'
                        : 'You received ${_donationStatus!.organType.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isDonor
                        ? 'To: ${_donationStatus!.recipientName}'
                        : 'From: ${_donationStatus!.donorName}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Timeline title
          Text(
            'Donation Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Timeline card
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStatusHistory(),
            ),
          ),

          const SizedBox(height: 24),

          // Details title
          Text(
            'Additional Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Details card
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Organ type', _donationStatus!.organType),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Completion date',
                    _formatDateTime(
                        _donationStatus!.statusHistory['followUpCare'] ??
                            _donationStatus!.statusTimestamp),
                  ),
                  if (_donationStatus!.adminNotes != null &&
                      _donationStatus!.adminNotes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow('Notes', _donationStatus!.adminNotes!),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Certificate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement certificate generation or viewing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Certificate feature coming soon')),
                );
              },
              icon: const Icon(Icons.card_membership),
              label: const Text('View Donation Certificate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Share button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement sharing functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing feature coming soon')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Your Story'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusHistory() {
    final sortedHistory = _donationStatus!.statusHistory.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value)); // Chronological order

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      separatorBuilder: (context, index) => Container(
        height: 20,
        width: 2,
        color: Colors.green,
        margin: const EdgeInsets.only(left: 19),
      ),
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        final statusKey = entry.key;
        final timestamp = entry.value;

        final statusType = DonationStatusType.values.firstWhere(
          (type) => type.toString().split('.').last == statusKey,
          orElse: () => DonationStatusType.matched,
        );

        final statusInfo =
            _donationStatus!.copyWith(status: statusType).getStatusInfo();

        final isLast = index == sortedHistory.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green,
              child: isLast
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : Text(
                      statusInfo['emoji'],
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusInfo['description'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
