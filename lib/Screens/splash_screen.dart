import 'dart:async';

import 'package:cr_admin/Features/authentication/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 5),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffB81736),
              Color(0xff281537),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your logo or image here
              Image.asset(
                'assets/splash-screen.gif',
                width: 150,
                height: 150,
              ),
              Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 33,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
