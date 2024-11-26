import 'package:cr_admin/Features/authentication/models/user_model.dart';
import 'package:cr_admin/Repositories/user_repository.dart';
import 'package:cr_admin/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  final userRepository = Get.put(UserRepository());

  // SAVE USER RECORD FROM ANY REGISTRATION PROVIDER
  Future<void> saveUserRecord(
      UserCredential? userCredential, double lat, double lon) async {
    try {
      if (userCredential != null) {
        // Fetch existing user data
        final existingUser =
            await userRepository.getUserData(userCredential.user!.uid);

        // Convert name to first and last name
        // final nameParts = UserModel.nameParts(userCredential.user?.displayName ?? '');

        // Create a new user model, merging with existing data if available
        final user = UserModel(
          id: userCredential.user!.uid,
          firstName: existingUser!.firstName,
          email: userCredential.user?.email ?? '',
          phoneNumber: userCredential.user?.phoneNumber ?? '',
          profilePicture: existingUser.profilePicture,
          latitude: lat,
          longitude: lon,
          percentage: existingUser.percentage,
          classCode: existingUser.classCode,
          subject: existingUser.subject,
          request: existingUser.request,
          userName: existingUser.userName,
          radius: existingUser.radius, studentId: existingUser.studentId, subjects: existingUser.subjects,
        );

        // Save user data
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Data Not Saved',
        message:
            'Something went wrong while saving your information. You can re-save your data in your profile.',
      );
    }
  }
}
