import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_admin/Features/authentication/controllers/authentication_repository.dart';
import 'package:cr_admin/Features/authentication/models/user_model.dart';
import 'package:cr_admin/Repositories/user_repository.dart';
import 'package:cr_admin/Screens/MainScreen/main_screen.dart';
import 'package:cr_admin/utils/constants/image_strings.dart';
import 'package:cr_admin/utils/popups/full_screen_loader.dart';
import 'package:cr_admin/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  // VARIABLES
  final hiddenPassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final firstName = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final classCode = TextEditingController();
  final studentId = TextEditingController();
  final latitude = 0.0.obs; // New variable to store latitude
  final longitude = 0.0.obs; // New variable to store longitude
  final selectedSection = ''.obs;
  // final imageFile = Rx<XFile?>(null);
  final Rx<Uint8List?> imageBinary = Rx<Uint8List?>(null);

  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  // Method to check if the username is unique
  Future<bool> isUserNameUnique(String userName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('admin')
        .where('userName', isEqualTo: userName)
        .get();

    return querySnapshot.docs.isEmpty;
  }


  Future<String> storeImage(
      Uint8List _image, UserCredential userCredintial) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('userProfile')
        .child(userCredintial.user!.uid);
    UploadTask uploadTask = ref.putData(_image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  // SIGNUP
  Future<void> signUp() async {
    try {
      // START LOADING
      TFullScreenLoader.openLoadingDialog(
        'We are processing your information',
        TImages.docerAnimation,
      );

      final authRepository = Get.put(AuthenticationRepository());

      // FORM VALIDATION
      if (!signUpFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading(); // Pass the BuildContext
        return;
      }

      // CHECK USERNAME UNIQUENESS
      final isUnique = await isUserNameUnique(userName.text.trim());
      if (!isUnique) {
        TFullScreenLoader.stopLoading(); // Pass the BuildContext
        TLoaders.warningSnackBar(
          title: 'Username Exists',
          message: 'Please choose a unique username.',
        );
        return;
      }

      // REGISTER USER IN THE FIREBASE AUTHENTICATION & SAVE USER DATA IN FIREBASE
      final userCredential = await authRepository.registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      String profilePic;
      if (imageBinary.value != null) {
        print('sankar');
        profilePic = await storeImage(imageBinary.value!, userCredential);
        print(profilePic);
      } else {
        // Handle the case when imageBinary is null
        // For example, you can use a default profile picture URL
        profilePic = 'https://example.com/default_profile_picture.png';
      }

      // UPLOAD IMAGE TO FIREBASE STORAGE
      // final profileImageUrl = await uploadImage();

      // SAVE AUTHENTICATED USER DATA IN FIREBASE FIRESTORE
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        email: email.text.trim(),
        classCode: selectedSection.value,
        phoneNumber: phoneNumber.text.trim(),
        percentage: 0.0,
        profilePicture: profilePic,
        latitude: latitude.value, // Assign the latitude value
        longitude: longitude.value, // Assign the longitude value
        subject: '',
        studentId: studentId.text.trim(),
        request: false,
        subjects:[],
        userName: userName.text.trim(),
        radius: 0,
      );
      print("SANKAR BEHERA");
      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // SHOW SUCCESS MESSAGE AND NAVIGATE
      TLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your account has been created.',
      );
      TFullScreenLoader.stopLoading(); // Pass the BuildContext
      Get.to(() => MainScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading(); // Pass the BuildContext
      TLoaders.errorSnackBar(title: 'ERROR', message: e.toString());
    }
  }
}
