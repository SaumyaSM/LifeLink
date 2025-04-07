import '../models/user_model.dart';
import 'user_service.dart';

class MatchingService {
  static Future<List<Map<String, dynamic>>> matchDonorsAndRecipients() async {
    List<UserModel> donors = await UserService.getDonors();
    List<UserModel> recipients = await UserService.getRecipients();

    List<Map<String, dynamic>> matches = [];

    for (var donor in donors) {
      for (var recipient in recipients) {
        int score = 0;

        //  Blood Group Compatibility
        if (!isBloodGroupCompatible(donor.bloodType, recipient.bloodType))
          continue;

        if (donor.organType != recipient.organType) continue;

        //  HLA Mismatch Calculation
        int hlaMismatch =
            calculateHLAMismatch(donor.hlaTyping, recipient.hlaTyping);
        score -= getMismatchScore(hlaMismatch);

        //  Waiting Time Score
        score += recipient.waitingTime;

        //  Recipient Age Score
        score += getAgeScore(recipient.dateOfBirth);

        //  Location Score
        if (donor.city == recipient.city) score += 200;

        matches.add({'donor': donor, 'recipient': recipient, 'score': score});
      }
    }

    matches.sort((a, b) => b['score'].compareTo(a['score']));

    return matches;
  }

  static bool isBloodGroupCompatible(String donor, String recipient) {
    Map<String, List<String>> compatibility = {
      'O': ['O', 'A', 'B', 'AB'],
      'A': ['A', 'AB'],
      'B': ['B', 'AB'],
      'AB': ['AB'],
    };
    return compatibility[donor]?.contains(recipient) ?? false;
  }

  static int calculateHLAMismatch(
      Map<String, String> donorHLA, Map<String, String> recipientHLA) {
    int mismatches = 0;
    List<String> loci = ["A", "B", "C", "DQB1", "DRB1"];

    for (var key in loci) {
      if (!donorHLA.containsKey(key) || !recipientHLA.containsKey(key))
        continue;

      List<String> donorAlleles =
          donorHLA[key]!.split(',').map((e) => e.trim()).toList();
      List<String> recipientAlleles =
          recipientHLA[key]!.split(',').map((e) => e.trim()).toList();

      for (var allele in donorAlleles) {
        if (!recipientAlleles.contains(allele)) {
          mismatches++;
        }
      }
    }

    return mismatches;
  }

  static int getMismatchScore(int mismatches) {
    if (mismatches == 0) return 0;
    if (mismatches <= 2) return 100;
    if (mismatches <= 5) return 250;
    if (mismatches <= 8) return 400;
    return 600;
  }

  static int getAgeScore(String birthDate) {
    // Assuming birthDate format is dd/MM/yyyy
    List<String> parts = birthDate.split('/');

    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    DateTime dob = DateTime(year, month, day);
    int age = DateTime.now().difference(dob).inDays ~/ 365;

    if (age <= 18) return 500;
    if (age <= 29) return 225;
    if (age <= 49) return 100;
    if (age <= 59) return 15;
    return 0;
  }
}
