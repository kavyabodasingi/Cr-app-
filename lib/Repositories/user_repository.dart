import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_admin/Features/authentication/models/user_model.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection('admin').doc(user.id).set(user.toJson());
    } catch (e) {
      throw 'something went wrong. please try again';
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _db.collection('admin').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromSnapshot(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }
}
