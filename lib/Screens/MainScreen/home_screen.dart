import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_admin/Screens/MainScreen/responce_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? lat;
  double? long;
  String address = "";
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  String? _selectedSubject;
  List<String> _subjects = []; // List to store fetched subjects
  final TextEditingController _radiusController = TextEditingController();
  bool _isLoading = false; // State to track loading state

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchSubjects(); // Fetch subjects when screen initializes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSubjects(); // Fetch subjects when dependencies change
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    stopLocationUpdates();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubjects() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('admin').doc(userId).get();
      List<dynamic> subjectsList = userDoc.get('subjects') ?? [];
      setState(() {
        _subjects = subjectsList.cast<String>();
      });
    } catch (e) {
      print('Error fetching subjects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subjects')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getLatLong() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        lat = position.latitude;
        long = position.longitude;
      });
      await getAddress(position.latitude, position.longitude);
    } catch (err) {
      print("ERROR: $err");
    }
  }

  Future<void> getAddress(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          address =
              "${place.street ?? 'Unknown street'}, ${place.locality ?? 'Unknown locality'}, ${place.country ?? 'Unknown country'}";
        });
      }
    } catch (e) {
      print("ERROR in getAddress: $e");
    }
  }

  Future<void> updateLocationToFirebase() async {
    if (lat == null || long == null) {
      print('Error: lat or long is null');
      return;
    }

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      int radius = int.tryParse(_radiusController.text) ?? 0;

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('admin').doc(userId);

      await userDocRef.update({
        'latitude': lat,
        'longitude': long,
        'subject': _selectedSubject,
        'request': true,
        'radius': radius + 30,
      });

      print('Location, subject, and radius updated successfully');
    } catch (e) {
      print('Error updating location, subject, and radius: $e');
    }
  }

  void startLocationUpdates() {
    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        lat = position.latitude;
        long = position.longitude;
      });
      updateLocationToFirebase();
    });
  }

  void stopLocationUpdates() {
    _positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)));

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth * 0.05;
          double fontSize = constraints.maxWidth * 0.04;
          double buttonPadding = constraints.maxWidth * 0.1;
          double buttonHeight = constraints.maxWidth * 0.15;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
                SizedBox(height: padding),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Colors.black.withOpacity(0.8),
                  style: const TextStyle(color: Colors.white),
                  value: _selectedSubject,
                  items: _subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a subject';
                    }
                    return null;
                  },
                ),
                SizedBox(height: padding),
                TextFormField(
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter radius",
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(height: padding),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator() // Show progress indicator if loading
                      : ElevatedButton(
                          onPressed: () async {
                            if (_selectedSubject != null) {
                              setState(() {
                                _isLoading = true; // Set loading state
                              });

                              try {
                                await getLatLong();
                                startLocationUpdates();
                                String userId = FirebaseAuth.instance.currentUser!.uid;
                                DocumentReference userDocRef = FirebaseFirestore.instance.collection('admin').doc(userId);
                                await FirebaseFirestore.instance.runTransaction((transaction) async {
                                  DocumentSnapshot freshSnapshot = await transaction.get(userDocRef);
                                  Map<String, dynamic>? data = freshSnapshot.data() as Map<String, dynamic>?;
                                  int currentCount = data?[_selectedSubject] ?? 0;
                                  transaction.update(userDocRef, {_selectedSubject!: currentCount + 1});
                                });
                                print('Subject count incremented successfully');
                                await updateLocationToFirebase();

                                // Increment the subject count after updating location
                                setState(() {
                                  _isLoading = false; // Reset loading state
                                });
                                Get.to(ResponseScreen(selectedSubject: _selectedSubject,));
                              } catch (e) {
                                setState(() {
                                  _isLoading = false; // Reset loading state on error
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }

                              print("Send button pressed");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please select a subject')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: buttonPadding, vertical: 15),
                            backgroundColor: Color(0xffB81736),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            minimumSize: Size(buttonHeight, buttonHeight),
                          ),
                          child: Text(
                            'Send',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize * 0.9),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
