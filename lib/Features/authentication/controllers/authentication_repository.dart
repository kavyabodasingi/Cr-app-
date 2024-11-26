import 'package:cr_admin/Features/authentication/screens/login/login_screen.dart';
import 'package:cr_admin/Screens/MainScreen/main_screen.dart';
import 'package:cr_admin/Screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();
  final _auth = FirebaseAuth.instance;
  final deviceStorage = GetStorage();

  @override
  void onReady() {
    // FlutterNativeSplash.remove();
    screenRedirect(_auth.currentUser);
  }

  // REGISTER USER
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  // LOGIN USER
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw 'An error occurred while signing in. Please try again: $e';
    }
  }

  // GOOGLE LOGIN USER
  Future<UserCredential?> loginWithGoogle() async {
    try {
      // TRIGGER THE AUTHENTICATION FLOW
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      if (userAccount == null) {
        throw 'Google sign-in was cancelled by the user.';
      }

      // OBTAIN THE AUTH DETAILS FROM THE REQUEST
      final GoogleSignInAuthentication googleAuth =
          await userAccount.authentication;

      // CREATE A NEW CREDENTIAL
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // ONCE SIGNED IN, RETURN THE USERCREDENTIAL
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw 'An error occurred during Google sign-in. Please try again: $e';
    }
  }

  // FUNCTION TO SHOW RELEVANT SCREEN
  void screenRedirect(User? user) {
    if (user != null) {
      // if (user.emailVerified) {
      //   Get.offAll(() => MainScreen());
      // } else {
      //   Get.offAll(() => VerifyEmail(
      //         email: _auth.currentUser?.email,
      //       ));
      // }
      Get.offAll(() => MainScreen());
    } else {
      // LOCAL STORAGE
      deviceStorage.writeIfNull('IsFirstTime', true);
      // CHECK IF IT'S THE FIRST TIME LAUNCHING THE APP
      if (deviceStorage.read('IsFirstTime') == true) {
        // Get.offAll(() => MainScreen());
        Get.offAll(() => SplashScreen());
      } else {
        Get.offAll(() => LoginScreen());
      }
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  // FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Something went wrong. Please try again: $e';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      throw 'An error occurred while logging out. Please try again: $e';
    }
  }
}
