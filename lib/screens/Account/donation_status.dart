import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/donation_status_model.dart';
import '../../services/auth_service.dart';
import '../../services/donation_status_service.dart';

class DonationStatusScreen extends StatefulWidget {
  final String? donationId;

  const DonationStatusScreen({Key? key, this.donationId}) : super(key: key);

  @override
  _DonationStatusScreenState createState() => _DonationStatusScreenState();
}

class _DonationStatusScreenState extends State<DonationStatusScreen> {
  final DonationStatusService _donationStatusService = DonationStatusService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  DonationStatus? _donationStatus;
  String? _currentUserId;
  bool _isUserInvolved = false;
  String _viewMode = 'timeline'; // 'timeline' or 'details'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUserId = await AuthService.getCurrentUserId();
      print('DEBUG - Current user ID: $_currentUserId');
      print('DEBUG - Donation ID from widget: ${widget.donationId}');

      if (widget.donationId != null) {
        print(
            'DEBUG - Loading specific donation with ID: ${widget.donationId}');

        try {
          _donationStatus = await _donationStatusService
              .getDonationStatus(widget.donationId!);
          print(
              'DEBUG - Loaded donation status: ${_donationStatus != null ? 'SUCCESS' : 'FAILED (null)'}');
          if (_donationStatus != null) {
            print(
                'DEBUG - Status details: ID=${_donationStatus!.id}, StatusIndex=${_donationStatus!.statusIndex}');
          }
        } catch (e) {
          print('DEBUG - Error loading specific donation: $e');
        }
      } else {
        print('DEBUG - No donation ID provided, searching for user donations');

        try {
          List<DonationStatus> userStatuses = [];
          try {
            userStatuses = await _donationStatusService
                .getUserDonationStatusesFuture(_currentUserId!);
            print('DEBUG - Retrieved ${userStatuses.length} user statuses');
          } catch (e) {
            print('DEBUG - Error getting user donation statuses: $e');
          }

          if (userStatuses.isNotEmpty) {
            print('DEBUG - Listing all retrieved statuses:');
            for (var i = 0; i < userStatuses.length; i++) {
              var status = userStatuses[i];
              print(
                  'DEBUG - Status $i: ID=${status.id}, DonorID=${status.donorId}, RecipientID=${status.recipientId}, StatusIndex=${status.statusIndex}');
            }

            print('DEBUG - Checking for active donations');
            userStatuses
                .sort((a, b) => b.statusTimestamp.compareTo(a.statusTimestamp));
            _donationStatus = userStatuses.first;
            print(
                'DEBUG - Selected most recent status: ID=${_donationStatus!.id}, StatusIndex=${_donationStatus!.statusIndex}');
          } else {
            print('DEBUG - No user donation statuses found');
          }
        } catch (e) {
          print('DEBUG - Error in user donations flow: $e');
        }
      }

      if (_donationStatus != null && _currentUserId != null) {
        _isUserInvolved = _donationStatus!.donorId == _currentUserId ||
            _donationStatus!.recipientId == _currentUserId;
        print(
            'DEBUG - User involved in donation: $_isUserInvolved (DonorID=${_donationStatus!.donorId}, RecipientID=${_donationStatus!.recipientId})');
      } else {
        print(
            'DEBUG - Cannot check involvement, donation status or user ID is null');
      }
    } catch (e) {
      print('DEBUG - Top level error in _loadData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading donation status: $e')),
      );
    } finally {
      print(
          'DEBUG - Final donation status: ${_donationStatus != null ? 'EXISTS' : 'NULL'}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Status'),
        elevation: 0,
        actions: [
          if (_donationStatus != null)
            IconButton(
              icon: Icon(
                  _viewMode == 'timeline' ? Icons.view_list : Icons.timeline),
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == 'timeline' ? 'details' : 'timeline';
                });
              },
              tooltip:
                  _viewMode == 'timeline' ? 'View Details' : 'View Timeline',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donationStatus == null
              ? _buildEmptyState()
              : _viewMode == 'timeline'
                  ? _buildTimelineView()
                  : _buildDetailsView(),
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
              Icons.medical_services_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Donation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are not currently part of an active donation process',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
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

  Widget _buildStatusHeader() {
    final statusInfo = _donationStatus!.getStatusInfo();
    final bool isRecipient = _currentUserId == _donationStatus!.recipientId;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.2),
                radius: 20,
                child: Text(
                  statusInfo['emoji'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecipient
                          ? 'Receiving ${_donationStatus!.organType} from ${_donationStatus!.donorName}'
                          : 'Donating ${_donationStatus!.organType} to ${_donationStatus!.recipientName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current status: ${statusInfo['title']}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (_donationStatus!.statusIndex + 1) /
                    DonationStatusType.values.length,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_donationStatus!.statusIndex + 1} of ${DonationStatusType.values.length}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                'Updated: ${_formatDateTime(_donationStatus!.statusTimestamp)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    final List<DonationStatusType> allStatuses = DonationStatusType.values;
    final currentStatusIndex = _donationStatus!.statusIndex;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _buildStatusHeader(),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: allStatuses.length,
              itemBuilder: (context, index) {
                final statusType = allStatuses[index];
                final statusInfo = _donationStatus!
                    .copyWith(status: statusType)
                    .getStatusInfo();
                final bool isCompleted = index <= currentStatusIndex;
                final bool isCurrent = index == currentStatusIndex;
                final String statusKey = statusType.toString().split('.').last;
                final DateTime? completedDate =
                    _donationStatus!.statusHistory[statusKey];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: isCurrent ? 2 : 1,
                    surfaceTintColor: Colors.white,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isCurrent
                          ? BorderSide(color: primaryColor, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: isCompleted
                                    ? Colors.green
                                    : index == currentStatusIndex + 1
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 16)
                                    : Text(
                                        (index + 1).toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                              if (index < allStatuses.length - 1)
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      statusInfo['emoji'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        statusInfo['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  statusInfo['description'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isCurrent
                                        ? Colors.black87
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                if (completedDate != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Completed: ${_formatDateTime(completedDate)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (isCurrent) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.hourglass_top,
                                            size: 12, color: primaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Current Status',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsView() {
    final statusInfo = _donationStatus!.getStatusInfo();
    final bool isRecipient = _currentUserId == _donationStatus!.recipientId;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor.withOpacity(0.2),
                              radius: 18,
                              child: Text(
                                statusInfo['emoji'],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    statusInfo['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Updated: ${_formatDateTime(_donationStatus!.statusTimestamp)}',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          statusInfo['description'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Donation Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Organ', _donationStatus!.organType),
                        const Divider(height: 16),
                        _buildDetailRow(
                          isRecipient ? 'Donor' : 'Recipient',
                          isRecipient
                              ? _donationStatus!.donorName
                              : _donationStatus!.recipientName,
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          'Progress',
                          '${_donationStatus!.statusIndex + 1} of ${DonationStatusType.values.length} steps',
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (_donationStatus!.statusIndex + 1) /
                                  DonationStatusType.values.length,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.7)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Status History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildStatusHistory(),
                  ),
                ),
                if (_donationStatus!.adminNotes != null &&
                    _donationStatus!.adminNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    surfaceTintColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_donationStatus!.adminNotes!,
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh Status'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistory() {
    final sortedHistory = _donationStatus!.statusHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(Icons.history, size: 32, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'No status history available',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      separatorBuilder: (context, index) =>
          Divider(height: 16, color: Colors.grey.shade300),
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

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusInfo['emoji'],
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusInfo['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(timestamp),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
