import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/services/auth_service.dart';

class UserService {
  static final userCollection = 'users';

  static Future<void> createUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap());
  }

  static Future<void> updateUserData(UserModel user) async {
    await FirebaseFirestore.instance.collection(userCollection).doc(user.id).update(user.toMap());
  }

  static Future<UserModel> getUserData() async {
    return UserModel.fromDocumentSnapshot(
      await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(AuthService.getLoggedUserID())
          .get(),
    );
  }
}
