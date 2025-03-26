import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/auth_service.dart';

class UserService {
  static final userCollection = 'users';

  static Future<void> createUser(UserModel user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }

  static Future<void> updateUserData(UserModel user) async {
    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(user.id)
        .update(user.toMap());
  }

  static Future<UserModel> getUserData() async {
    return UserModel.fromDocumentSnapshot(
      await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(AuthService.getLoggedUserID())
          .get(),
    );
  }

  static Future<List<UserModel>> getDonors() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDonor', isEqualTo: true)
        // .where('isTestsCompleted', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromDocumentSnapshot(doc))
        .toList();
  }

  static Future<List<UserModel>> getRecipients() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDonor', isEqualTo: false)
        // .where('isTestsCompleted', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromDocumentSnapshot(doc))
        .toList();
  }
}
