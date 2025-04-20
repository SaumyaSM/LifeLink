import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/view_details_screen.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:life_link/services/organ_matching_service.dart';
import 'package:life_link/services/user_service.dart';

class ExploreScreen extends StatefulWidget {
  final bool isDonor;

  const ExploreScreen({super.key, required this.isDonor});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  UserModel? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = AuthService.getLoggedUserID();
      _currentUser = await UserService.getUserById(userId);
      await _loadUsers();
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading user data: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<UserModel> users = await UserService.fetchUsers();

      // Filter users to show only opposite type (donors or recipients)
      users =
          users.where((user) => user.isDonor != _currentUser!.isDonor).toList();

      // If user is a recipient, pre-filter to show only compatible donors
      if (!_currentUser!.isDonor && _currentUser!.bloodType != null) {
        users = users
            .where((donor) =>
                donor.bloodType != null &&
                MatchingService.isBloodGroupCompatible(
                    donor.bloodType!, _currentUser!.bloodType!) &&
                donor.organType == _currentUser!.organType)
            .toList();
      }

      // If user is a donor, pre-filter to show only compatible recipients
      if (_currentUser!.isDonor && _currentUser!.bloodType != null) {
        users = users
            .where((recipient) =>
                recipient.bloodType != null &&
                MatchingService.isBloodGroupCompatible(
                    _currentUser!.bloodType!, recipient.bloodType!) &&
                recipient.organType == _currentUser!.organType)
            .toList();
      }

      _allUsers = users;
      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      _errorMessage = "Error loading users: ${e.toString()}";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
        return;
      }

      final lowercaseQuery = query.toLowerCase();
      _filteredUsers = _allUsers
          .where((user) =>
              user.fullName.toLowerCase().contains(lowercaseQuery) ||
              user.bloodType.toLowerCase().contains(lowercaseQuery) ||
              user.organType.toLowerCase().contains(lowercaseQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCompatibilityNotice(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Explore",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: kRedColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildCompatibilityNotice() {
    if (_currentUser == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green.withOpacity(0.1),
      child: Text(
        _currentUser!.isDonor
            ? "Showing compatible recipients for your ${_currentUser!.organType} donation with blood type ${_currentUser!.bloodType}"
            : "Showing compatible donors for your ${_currentUser!.organType} need with blood type ${_currentUser!.bloodType}",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _filterUsers,
        decoration: InputDecoration(
          hintText: 'Search by name, blood type or organ...',
          prefixIcon: const Icon(Icons.search, color: kRedColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterUsers('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kRedColor));
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorView();
    }

    if (_filteredUsers.isEmpty) {
      return _buildEmptyResultsView();
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: kRedColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _filteredUsers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) =>
              _buildUserCard(_filteredUsers[index]),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(backgroundColor: kRedColor),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _allUsers.isEmpty
                ? "No compatible matches found"
                : "No matching results found",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    // Calculate compatibility badge
    bool isBloodCompatible = false;
    if (_currentUser != null &&
        _currentUser!.bloodType != null &&
        user.bloodType != null) {
      isBloodCompatible = _currentUser!.isDonor
          ? MatchingService.isBloodGroupCompatible(
              _currentUser!.bloodType!, user.bloodType!)
          : MatchingService.isBloodGroupCompatible(
              user.bloodType!, _currentUser!.bloodType!);
    }

    return GestureDetector(
      onTap: () => _handleCardTap(user),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserImage(user),
            Expanded(child: _buildUserInfo(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserImage(UserModel user) {
    return Stack(
      children: [
        FutureBuilder<String?>(
          future: UserService().fetchProfileImage(user.id),
          builder: (context, snapshot) {
            final imageUrl = snapshot.data ?? user.imageUrl;

            return Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            );
          },
        ),

        // Compatibility indicator
        if (_currentUser != null && _currentUser!.organType == user.organType)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _buildBloodTypeBadge(user.bloodType),
          const SizedBox(height: 8),
          Text(
            user.isDonor ? "Donating:" : "Needs:",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            user.organType,
            style: TextStyle(
              color: user.isDonor ? Colors.green : Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeBadge(String bloodType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bloodType,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  Future<void> _handleCardTap(UserModel selectedUser) async {
    final String currentUserId = AuthService.getLoggedUserID();

    _showLoadingDialog();

    try {
      final matches = await UserService.fetchUserMatches();
      final match = _findMatchForUser(matches, selectedUser);

      // Close loading dialog
      Navigator.of(context).pop();

      // Process match data and navigate
      if (match.isEmpty) {
        await _handleNewMatch(currentUserId, selectedUser);
      } else {
        _navigateToDetailsWithExistingMatch(match, currentUserId);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackbar(e);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  Map<String, dynamic> _findMatchForUser(
      List<dynamic> matches, UserModel selectedUser) {
    return matches.firstWhere(
      (m) {
        final donor = m['donor'];
        final recipient = m['recipient'];
        return donor.id == selectedUser.id || recipient.id == selectedUser.id;
      },
      orElse: () => <String, dynamic>{}, // Explicitly typed empty map
    );
  }

  Future<void> _handleNewMatch(
      String currentUserId, UserModel selectedUser) async {
    final currentUser = await UserService.getUserById(currentUserId);
    final UserModel donor = currentUser.isDonor ? currentUser : selectedUser;
    final UserModel recipient =
        currentUser.isDonor ? selectedUser : currentUser;
    final bool isUserDonor = currentUser.isDonor;

    // Use the MatchingService to calculate the score instead of duplicating logic
    final int score =
        await MatchingService.calculateMatchScore(donor, recipient);

    _navigateToDetailsScreen(donor, recipient, score, isUserDonor);
  }

  void _navigateToDetailsWithExistingMatch(
      Map<String, dynamic> match, String currentUserId) {
    final UserModel donor = match['donor'];
    final UserModel recipient = match['recipient'];
    final int score = match['score'] ?? 0;
    final bool isUserDonor = donor.id == currentUserId;

    _navigateToDetailsScreen(donor, recipient, score, isUserDonor);
  }

  void _navigateToDetailsScreen(
      UserModel donor, UserModel recipient, int score, bool isUserDonor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewDetailsScreen(
          user: isUserDonor ? recipient : donor,
          currentUser: isUserDonor ? donor : recipient,
          matchScore: score,
          isUserDonor: isUserDonor,
        ),
      ),
    );
  }

  void _showErrorSnackbar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading match details: $error')),
    );
  }
}
