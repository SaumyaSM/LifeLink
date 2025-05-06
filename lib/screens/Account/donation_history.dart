import 'package:flutter/material.dart';
import '../../models/donation_status_model.dart';
import '../../services/auth_service.dart';
import '../../services/donation_status_service.dart';
import '../../services/user_service.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  _DonationHistoryScreenState createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  final DonationStatusService _donationStatusService = DonationStatusService();
  String? _currentUserId;
  bool _isLoading = true;
  List<DonationStatus> _completedDonations = [];
  bool _isDonor = true;

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

      final user = await UserService.getUserById(_currentUserId!);
      if (user != null) {
        _isDonor = user.isDonor;
      }

      List<DonationStatus> userStatuses = await _donationStatusService
          .getUserDonationStatusesFuture(_currentUserId!);

      _completedDonations = userStatuses
          .where((status) =>
              status.status == DonationStatusType.followUpCare &&
              (_isDonor
                  ? status.donorId == _currentUserId
                  : status.recipientId == _currentUserId))
          .toList();

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedDonations.isEmpty
              ? _buildEmptyState()
              : _buildDonationHistoryList(),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with icon, title and status
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
            const SizedBox(height: 12),

            // Details section
            Text(
              'Additional Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            _buildDetailRow('Organ type', donation.organType),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Completion date',
              _formatDateTime(donation.statusHistory['followUpCare'] ??
                  donation.statusTimestamp),
            ),

            const SizedBox(height: 8),
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
          ],
        ),
      ),
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
