import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/view_details_screen.dart';
import 'package:life_link/services/auth_service.dart';

import '../services/user_service.dart';

class ExploreScreen extends StatefulWidget {
  final bool isDonor;

  ExploreScreen({super.key, required this.isDonor});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Future<List<UserModel>>? _usersFuture;
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _allUsers = await UserService.fetchUsers();
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
      } else {
        _filteredUsers = _allUsers
            .where((user) =>
                user.fullName.toLowerCase().contains(query.toLowerCase()) ||
                user.bloodType.toLowerCase().contains(query.toLowerCase()) ||
                user.organType.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildUserList(),
          ),
        ],
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

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _allUsers.isEmpty
                  ? "No users found in the system"
                  : "No matching results found",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
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
          itemBuilder: (context, index) {
            return _buildUserCard(_filteredUsers[index]);
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return GestureDetector(
      onTap: () => _handleCardTap(user),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            FutureBuilder<String?>(
              future: UserService()
                  .fetchProfileImage(user.id), // Fetch latest image
              builder: (context, snapshot) {
                String? imageUrl = snapshot.data ?? user.imageUrl;

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
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        )
                      : null,
                );
              },
            ),

            // Info Section
            Expanded(
              child: Padding(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.bloodType,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.isDonor ? "Donating:" : "Needs:",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(UserModel selectedUser) async {
    final String currentUserId = AuthService.getLoggedUserID();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final matches = await UserService.fetchUserMatches();

      final match = matches.firstWhere(
        (m) {
          final donor = m['donor'];
          final recipient = m['recipient'];
          return donor.id == selectedUser.id || recipient.id == selectedUser.id;
        },
        orElse: () => {},
      );

      Navigator.of(context).pop();

      UserModel donor;
      UserModel recipient;
      int score = 0;
      bool isUserDonor;

      if (match.isEmpty) {
        final currentUser = await UserService.getUserById(currentUserId);
        donor = currentUser.isDonor ? currentUser : selectedUser;
        recipient = currentUser.isDonor ? selectedUser : currentUser;
        isUserDonor = currentUser.isDonor;
      } else {
        donor = match['donor'];
        recipient = match['recipient'];
        score = match['score'] ?? 0;
        isUserDonor = donor.id == currentUserId;
      }

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
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading match details: $e')),
      );
    }
  }
}
