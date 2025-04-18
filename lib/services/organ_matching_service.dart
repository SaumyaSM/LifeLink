import '../models/user_model.dart';
import 'user_service.dart';

// / Matches organ donors to recipients based on medical compatibility and other factors.
// / Returns a sorted list of potential matches with their compatibility scores.
// / Higher scores indicate better matches.
// /
// / Scoring factors include:
// / - Blood type compatibility (required)
// / - Organ type match (required)
// / - HLA matching (penalty of 0-500 points)
// / - Recipient waiting time (points equal to days waited)
// / - Recipient age (0-500 points, prioritizing younger recipients)
// / - Location proximity (200 points for same city)
// / - Age difference (quadratic penalty for large age differences)

class MatchingService {
  static Future<List<Map<String, dynamic>>> matchDonorsAndRecipients() async {
    List<Map<String, dynamic>> matches = [];

    try {
      List<UserModel> donors = await UserService.getDonors();
      List<UserModel> recipients = await UserService.getRecipients();

      Map<String, List<UserModel>> recipientsByOrgan = {};
      for (var recipient in recipients) {
        String? organType = recipient.organType;
        if (organType == null) continue;

        recipientsByOrgan.putIfAbsent(organType, () => []);
        recipientsByOrgan[organType]!.add(recipient);
      }

      for (var donor in donors) {
        String? donorOrganType = donor.organType;
        String? donorBloodType = donor.bloodType;

        if (donorOrganType == null || donorBloodType == null) continue;

        List<UserModel> potentialRecipients =
            recipientsByOrgan[donorOrganType] ?? [];

        for (var recipient in potentialRecipients) {
          String? recipientBloodType = recipient.bloodType;
          if (recipientBloodType == null) continue;

          if (!isBloodGroupCompatible(donorBloodType, recipientBloodType)) {
            continue;
          }

          int score = 0;

          int hlaMismatch =
              calculateHLAMismatch(donor.hlaTyping, recipient.hlaTyping);
          score -= getMismatchScore(hlaMismatch);

          // Use null-safe access with a default value
          score += recipient.waitingTime ?? 0;

          String? recipientBirthDate = recipient.dateOfBirth;
          if (recipientBirthDate != null &&
              isValidBirthDate(recipientBirthDate)) {
            score += getAgeScore(recipientBirthDate);
          }

          String? donorCity = donor.city;
          String? recipientCity = recipient.city;
          if (donorCity != null &&
              recipientCity != null &&
              donorCity == recipientCity) {
            score += 200;
          }

          String? donorBirthDate = donor.dateOfBirth;
          if (donorBirthDate != null &&
              recipientBirthDate != null &&
              isValidBirthDate(donorBirthDate) &&
              isValidBirthDate(recipientBirthDate)) {
            score +=
                getAgeDifferencePenalty(donorBirthDate, recipientBirthDate);
          }

          matches.add({'donor': donor, 'recipient': recipient, 'score': score});
        }
      }

      matches.sort((a, b) => b['score'].compareTo(a['score']));
    } catch (e) {
      // Use a logger instead of print in production code
      // logger.error('Error in matching process: $e');
      // Or rethrow the exception
      rethrow;
    }

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
      Map<String, String>? donorHLA, Map<String, String>? recipientHLA) {
    int mismatches = 0;
    List<String> loci = ["A", "B", "C", "DQB1", "DRB1"];

    if (donorHLA == null || recipientHLA == null) {
      return 10;
    }

    for (var key in loci) {
      if (!donorHLA.containsKey(key) || !recipientHLA.containsKey(key)) {
        mismatches++;
        continue;
      }

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
    if (mismatches <= 1) return 100;
    if (mismatches <= 3) return 150;
    if (mismatches <= 8) return 250;
    return 500;
  }

  static int getAgeScore(String birthDate) {
    int age = calculateAge(birthDate);

    if (age <= 18) return 500;
    if (age <= 29) return 225;
    if (age <= 49) return 100;
    if (age <= 59) return 15;
    return 0;
  }

  static int getAgeDifferencePenalty(
      String donorBirthDate, String recipientBirthDate) {
    int donorAge = calculateAge(donorBirthDate);
    int recipientAge = calculateAge(recipientBirthDate);

    int ageDifference = (donorAge - recipientAge).abs();

    return (-0.5 * ageDifference * ageDifference).toInt(); // Quadratic penalty
  }

  static int calculateAge(String birthDate) {
    try {
      List<String> parts = birthDate.split('/');
      if (parts.length != 3) return 0;

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime dob = DateTime(year, month, day);
      DateTime today = DateTime.now();

      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }

  static bool isValidBirthDate(String birthDate) {
    try {
      List<String> parts = birthDate.split('/');
      if (parts.length != 3) return false;

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<int> calculateMatchScore(
      UserModel donor, UserModel recipient) async {
    // Start with base score
    int score = 0;

    // Skip if essential fields are missing or blood types aren't compatible
    if (donor.organType == null ||
        recipient.organType == null ||
        donor.bloodType == null ||
        recipient.bloodType == null ||
        donor.organType != recipient.organType ||
        !isBloodGroupCompatible(donor.bloodType!, recipient.bloodType!)) {
      return 0;
    }

    // Calculate HLA mismatch score
    int hlaMismatch =
        calculateHLAMismatch(donor.hlaTyping, recipient.hlaTyping);
    score -= getMismatchScore(hlaMismatch);

    // Add waiting time points
    score += recipient.waitingTime ?? 0;

    // Add age-based score for recipient
    if (recipient.dateOfBirth != null &&
        isValidBirthDate(recipient.dateOfBirth!)) {
      score += getAgeScore(recipient.dateOfBirth!);
    }

    // Add location bonus
    if (donor.city != null &&
        recipient.city != null &&
        donor.city == recipient.city) {
      score += 200;
    }

    // Add age difference penalty
    if (donor.dateOfBirth != null &&
        recipient.dateOfBirth != null &&
        isValidBirthDate(donor.dateOfBirth!) &&
        isValidBirthDate(recipient.dateOfBirth!)) {
      score +=
          getAgeDifferencePenalty(donor.dateOfBirth!, recipient.dateOfBirth!);
    }

    // Ensure score is not negative
    return score < 0 ? 0 : score;
  }
}
