import '../models/user_model.dart';
import 'dart:math';

class ScoringUtils {
  static Map<String, List<String>> bloodGroupCompatibility = {
    'O': ['O', 'A', 'B', 'AB'],
    'A': ['A', 'AB'],
    'B': ['B', 'AB'],
    'AB': ['AB'],
  };

  /// Blood Group Compatibility Check
  static bool isBloodGroupCompatible(String donorBlood, String recipientBlood) {
    return bloodGroupCompatibility[donorBlood]?.contains(recipientBlood) ??
        false;
  }

  /// HLA Mismatch Score Calculation
  static int calculateHLAMismatchScore(UserModel donor, UserModel recipient) {
    int mismatches = 0;
    donor.hlaTyping.forEach((key, value) {
      if (recipient.hlaTyping[key] != value) {
        mismatches++;
      }
    });

    if (mismatches == 0) return 0;
    if (mismatches == 1) return -100;
    if (mismatches >= 2 && mismatches <= 3) return -150;
    if (mismatches >= 4 && mismatches <= 8) return -250;
    return -500;
  }

  /// Age Calculation (from DOB)
  static int calculateAge(String dob) {
    try {
      DateTime birthDate = DateTime.parse(dob);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0; // default if parsing fails
    }
  }

  /// Recipient Age Score
  static int calculateAgeScore(int age) {
    if (age <= 18) return 500;
    if (age <= 29) return 225;
    if (age <= 49) return 100;
    if (age <= 59) return 15;
    return 0;
  }

  /// Age Difference Score
  static int calculateAgeDifferenceScore(int donorAge, int recipientAge) {
    int diff = donorAge - recipientAge;
    return (-0.5 * pow(diff, 2)).toInt();
  }

  /// Location Score
  static int calculateLocationScore(String donorCity, String recipientCity) {
    return donorCity.trim().toLowerCase() == recipientCity.trim().toLowerCase()
        ? 200
        : 0;
  }

  /// Previous Organ Donation Score
  static int calculatePreviousDonationScore(UserModel recipient) {
    // Assuming 'donated' keyword in history list
    return recipient.history.contains('donated') ? 150 : 0;
  }
}
