import 'package:cr_admin/Features/authentication/controllers/authentication_repository.dart';
import 'package:cr_admin/Screens/splash_screen.dart';
import 'package:cr_admin/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((FirebaseApp value) => Get.put(AuthenticationRepository()));

  // Check location permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // If location permission is denied, close the app
      return;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // initialBinding: GeneralBindings(),
      debugShowCheckedModeBanner: false,
      // theme: MyAppTheme.lightTheme,
      themeMode: ThemeMode.system,
      // darkTheme: MyAppTheme.darkTheme,
      home: SplashScreen(),
    );
  }
}
