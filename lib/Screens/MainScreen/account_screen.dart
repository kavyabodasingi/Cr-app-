import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_admin/Features/authentication/controllers/authentication_repository.dart';
import 'package:cr_admin/Features/authentication/screens/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? name;
  String? email;
  String? userName;
  String? studentId;
  String? classCode;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      print("User ID: $userId");
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('admin').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc['firstName'];
          email = userDoc['email'];
          userName = userDoc['userName'];
          studentId = userDoc['studentId'];
          classCode = userDoc['classCode'];
          _profileImageUrl = userDoc['profilePicture'];
          print("Data fetched successfully");
        });
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationRepository());

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth * 0.05;
          double avatarRadius = constraints.maxWidth * 0.15;
          double fontSizeTitle = constraints.maxWidth * 0.06;
          double fontSizeSubTitle = constraints.maxWidth * 0.04;
          double buttonPadding = constraints.maxWidth * 0.1;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/avatar.jpg') as ImageProvider,
                    ),
                    SizedBox(height: padding),
                    Text(
                      name ?? 'Loading...',
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: padding * 0.5),
                    Text(
                      email ?? 'Loading...',
                      style: TextStyle(
                        fontSize: fontSizeSubTitle,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: padding * 0.5),
                    Divider(color: Colors.white),
                    SizedBox(height: padding * 0.5),
                    _buildInfoRow('Username', userName ?? 'Loading...', fontSizeSubTitle),
                    SizedBox(height: padding * 0.5),
                    _buildInfoRow('ID No', studentId ?? 'Loading...', fontSizeSubTitle),
                    SizedBox(height: padding * 0.5),
                    _buildInfoRow('Class Code', classCode ?? 'Loading...', fontSizeSubTitle),
                    SizedBox(height: padding),
                    ElevatedButton(
                      onPressed: () {
                        controller.logout();
                        Get.offAll(() => LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: 15),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeSubTitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
