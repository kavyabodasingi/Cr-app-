import 'package:cr_admin/Features/authentication/controllers/authentication_repository.dart';
import 'package:cr_admin/Features/authentication/controllers/user_controller.dart';
import 'package:cr_admin/Screens/MainScreen/main_screen.dart';
import 'package:cr_admin/utils/constants/image_strings.dart';
import 'package:cr_admin/utils/popups/full_screen_loader.dart';
import 'package:cr_admin/utils/popups/loaders.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  // VARIABLES
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final latitude = 0.0.obs; // New variable to store latitude
  final longitude = 0.0.obs; // New variable to store longitude
  final loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    // Load remembered credentials if available
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
      // START LOADING
      TFullScreenLoader.openLoadingDialog('Logging You In', TImages.docerAnimation);

      // FORM VALIDATION
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // LOGIN USER USING EMAIL & PASSWORD AUTHENTICATION
      final userCredential = await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // SAVE USER RECORD WITH LATITUDE AND LONGITUDE
      // await userController.saveUserRecord(userCredential, latitude.value, longitude.value);

      // REMOVE LOADER
      TFullScreenLoader.stopLoading();

      // Navigate to MainScreen
      Get.offAll(() => MainScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'ERROR', message: e.toString());
    }
  }

  // GOOGLE SIGN IN
  Future<void> googleLogin() async {
    try {
      // START LOADING
      TFullScreenLoader.openLoadingDialog('Logging You In', TImages.docerAnimation);

      // GOOGLE AUTHENTICATION
      final userCredential = await AuthenticationRepository.instance.loginWithGoogle();

      // SAVE USER RECORD WITH LATITUDE AND LONGITUDE
      await userController.saveUserRecord(userCredential, latitude.value, longitude.value);

      // REMOVE LOADER
      TFullScreenLoader.stopLoading();

      // Navigate to MainScreen
      Get.offAll(() => MainScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'ERROR', message: e.toString());
    }
  }
}
