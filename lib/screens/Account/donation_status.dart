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
      // STEP 1: Get current user ID - Log this
      _currentUserId = await AuthService.getCurrentUserId();
      print('DEBUG - Current user ID: $_currentUserId');

      // STEP 2: Check if we have a donation ID
      print('DEBUG - Donation ID from widget: ${widget.donationId}');

      // STEP 3: Load donation status
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
          // Get all user statuses
          List<DonationStatus> userStatuses = [];
          try {
            userStatuses = await _donationStatusService
                .getUserDonationStatusesFuture(_currentUserId!);
            print('DEBUG - Retrieved ${userStatuses.length} user statuses');
          } catch (e) {
            print('DEBUG - Error getting user donation statuses: $e');
          }

          // Print all retrieved statuses
          if (userStatuses.isNotEmpty) {
            print('DEBUG - Listing all retrieved statuses:');
            for (var i = 0; i < userStatuses.length; i++) {
              var status = userStatuses[i];
              print(
                  'DEBUG - Status $i: ID=${status.id}, DonorID=${status.donorId}, RecipientID=${status.recipientId}, StatusIndex=${status.statusIndex}');
            }

            // Try to find an active status
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

      // STEP 4: Check user involvement
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Status'),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services_outlined,
              size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No active donation process found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are not currently part of an active donation process',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    final List<DonationStatusType> allStatuses = DonationStatusType.values;
    final currentStatusIndex = _donationStatus!.statusIndex;

    return Column(
      children: [
        _buildStatusHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: allStatuses.length,
              itemBuilder: (context, index) {
                final statusType = allStatuses[index];
                final statusInfo = _donationStatus!
                    .copyWith(status: statusType)
                    .getStatusInfo();
                final bool isCompleted = index <= currentStatusIndex;
                final bool isCurrent = index == currentStatusIndex;

                // Check if this status is in the history
                final String statusKey = statusType.toString().split('.').last;
                final DateTime? completedDate =
                    _donationStatus!.statusHistory[statusKey];

                return Card(
                  elevation: isCurrent ? 3 : 1,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isCurrent ? Colors.blue.shade50 : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrent
                        ? BorderSide(
                            color: Theme.of(context).primaryColor, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status indicator
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isCompleted
                                  ? Colors.green
                                  : index == currentStatusIndex + 1
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                              child: isCompleted
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 28)
                                  : Text(
                                      (index + 1).toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                            if (index < allStatuses.length - 1)
                              Container(
                                width: 2,
                                height: 40,
                                color: isCompleted
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Status content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    statusInfo['emoji'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      statusInfo['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                statusInfo['description'],
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.black87
                                      : Colors.grey.shade700,
                                ),
                              ),
                              if (completedDate != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Completed on: ${_formatDateTime(completedDate)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (isCurrent) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Current Status',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildStatusHeader() {
    final statusInfo = _donationStatus!.getStatusInfo();
    final bool isRecipient = _currentUserId == _donationStatus!.recipientId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 24,
                child: Text(
                  statusInfo['emoji'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecipient
                          ? 'Receiving ${_donationStatus!.organType} from ${_donationStatus!.donorName}'
                          : 'Donating ${_donationStatus!.organType} to ${_donationStatus!.recipientName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current status: ${statusInfo['title']}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_donationStatus!.statusIndex + 1) /
                DonationStatusType.values.length,
            backgroundColor: Colors.grey.shade200,
            color: Theme.of(context).primaryColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${_formatDateTime(_donationStatus!.statusTimestamp)}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView() {
    final statusInfo = _donationStatus!.getStatusInfo();
    final bool isRecipient = _currentUserId == _donationStatus!.recipientId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.2),
                        radius: 24,
                        child: Text(
                          statusInfo['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusInfo['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Updated: ${_formatDateTime(_donationStatus!.statusTimestamp)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusInfo['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Donation Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow('Organ', _donationStatus!.organType),
                  const Divider(),
                  _buildDetailRow(
                    isRecipient ? 'Donor' : 'You are donating to',
                    isRecipient
                        ? _donationStatus!.donorName
                        : _donationStatus!.recipientName,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Progress',
                    '${_donationStatus!.statusIndex + 1} of ${DonationStatusType.values.length} steps',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_donationStatus!.statusIndex + 1) /
                        DonationStatusType.values.length,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).primaryColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Status History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStatusHistory(),
            ),
          ),
          const SizedBox(height: 24),
          if (_donationStatus!.adminNotes != null &&
              _donationStatus!.adminNotes!.isNotEmpty) ...[
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_donationStatus!.adminNotes!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistory() {
    // Sort status history by dates
    final sortedHistory = _donationStatus!.statusHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No status history available'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        final statusKey = entry.key;
        final timestamp = entry.value;

        // Convert status key to status type
        final statusType = DonationStatusType.values.firstWhere(
          (type) => type.toString().split('.').last == statusKey,
          orElse: () => DonationStatusType.matched,
        );

        // Get status info
        final statusInfo =
            _donationStatus!.copyWith(status: statusType).getStatusInfo();

        return Row(
          children: [
            Text(
              statusInfo['emoji'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusInfo['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDateTime(timestamp),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
