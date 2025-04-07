import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/organ_matching_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    String currentUserId = AuthService.getLoggedUserID();

    List<Map<String, dynamic>> matchedPairs =
        await MatchingService.matchDonorsAndRecipients();

    List<Map<String, dynamic>> userMatches = matchedPairs.where((match) {
      UserModel donor = match['donor'];
      UserModel recipient = match['recipient'];

      return donor.id == currentUserId || recipient.id == currentUserId;
    }).toList();

    setState(() {
      matches = userMatches;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organ Matches"),
        backgroundColor: kPinkColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? const Center(child: Text("No Matches Found"))
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    UserModel donor = matches[index]['donor'];
                    UserModel recipient = matches[index]['recipient'];
                    int score = matches[index]['score'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          "${donor.fullName} & ${recipient.fullName}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Donor Blood Type: ${donor.bloodType}"),
                            Text(
                                "Recipient Blood Type: ${recipient.bloodType}"),
                            Text("Organ: ${donor.organType}"),
                            Text("Matching Score: $score"),
                          ],
                        ),
                        trailing: Icon(
                          Icons.favorite,
                          color: score > 500 ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
