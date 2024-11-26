import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_admin/Screens/MainScreen/data_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'account_screen.dart';
import 'home_screen.dart';
import 'manual_attendance_screen.dart';
import 'view_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _profileImageUrl; // Variable to store the profile image URL

  @override
  void initState() {
    super.initState();
    _loadTimetableEntries();
    _fetchProfileImage(); // Fetch profile image on initialization
  }

  Future<void> _loadTimetableEntries() async {
    // Fetch timetable entries here
  }

  Future<void> _fetchProfileImage() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('admin').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc['profilePicture'];
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AccountScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffB81736),
        title: const Text('Attendance Screen', style: TextStyle(color: Colors.white)),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xffB81736),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffB81736), Color(0xff281537)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/avatar.jpg'), // Default image
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('View'),
              onTap: () {
                Get.to(const ViewScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Manual Attendance'),
              onTap: () {
                Navigator.pop(context);
                Get.to(const ManualAttendanceScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Data Entry'),
              onTap: () {
                Navigator.pop(context);
                Get.to(const DataEntry());
              },
            ),
          ],
        ),
      ),
    );
  }
}
