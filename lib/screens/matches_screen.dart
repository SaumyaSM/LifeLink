import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/screens/view_details_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/organ_matching_service.dart';
import '../services/user_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> excellentMatches = [];
  bool isLoading = true;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    setState(() {
      isLoading = true;
    });

    currentUserId = await AuthService.getCurrentUserId();

    List<Map<String, dynamic>> userMatches =
        await UserService.fetchUserMatches();

    // Filter for excellent matches only (score > 700)
    List<Map<String, dynamic>> filteredMatches =
        userMatches.where((match) => match['score'] > 700).toList();

    setState(() {
      excellentMatches = filteredMatches;
      isLoading = false;
    });
  }

  // Simplified match color function that only returns green for excellent matches
  Color getMatchColor() {
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Excellent Matches",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kPinkColor,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPinkColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: kPinkColor,
                ),
              )
            : excellentMatches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Excellent Matches Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Check back later for excellent organ matches",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: excellentMatches.length,
                    itemBuilder: (context, index) {
                      UserModel donor = excellentMatches[index]['donor'];
                      UserModel recipient =
                          excellentMatches[index]['recipient'];
                      int score = excellentMatches[index]['score'];

                      Color matchColor = getMatchColor();

                      UserModel user =
                          donor.id == currentUserId ? recipient : donor;
                      bool isUserDonor = donor.id == currentUserId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: matchColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: matchColor.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: matchColor,
                                      radius: 20,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.fullName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 2),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: matchColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    "Score: $score",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: matchColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    "Excellent Match",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      "Organ Type: ",
                                      donor.organType,
                                      Icons.medical_services_outlined,
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isUserDonor
                                                    ? "You (Donor)"
                                                    : "Donor",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 14,
                                                    backgroundColor:
                                                        Colors.blue,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      isUserDonor
                                                          ? "You"
                                                          : donor.fullName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              _buildBloodTypeChip(
                                                  donor.bloodType),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 60,
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: Text(
                                                  isUserDonor
                                                      ? "Recipient"
                                                      : "You (Recipient)",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: Row(
                                                  children: [
                                                    const CircleAvatar(
                                                      radius: 14,
                                                      backgroundColor:
                                                          kPinkColor,
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        isUserDonor
                                                            ? recipient.fullName
                                                            : "You",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: _buildBloodTypeChip(
                                                    recipient.bloodType),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to view details screen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewDetailsScreen(
                                              user: donor.id == currentUserId
                                                  ? recipient
                                                  : donor,
                                              currentUser:
                                                  donor.id == currentUserId
                                                      ? donor
                                                      : recipient,
                                              matchScore: score,
                                              isUserDonor:
                                                  donor.id == currentUserId,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPinkColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        minimumSize:
                                            const Size(double.infinity, 44),
                                      ),
                                      child: const Text("View Details"),
                                    ),
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
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeChip(String bloodType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kRedColor.withOpacity(0.1),
        border: Border.all(color: kRedColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bloodType,
        style: TextStyle(
          color: kRedColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
