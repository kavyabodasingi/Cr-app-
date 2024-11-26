import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  DateTime? _selectedDate;
  String? _selectedSubject;
  bool _isTableVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _attendanceData = [];
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  void _fetchSubjects() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            _subjects = List<String>.from(documentSnapshot.get('subjects'));
          });
        } else {
          print('Document does not exist on the database');
        }
      }).catchError((error) {
        print('Error fetching subjects: $error');
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isTableVisible = false;
      });
    }
  }

  void _filterData() {
    setState(() {
      _attendanceData.clear();
      if (_selectedDate != null && _selectedSubject != null) {
        FirebaseFirestore.instance
            .collection('attendance')
            .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDate!))
            .where('subject', isEqualTo: _selectedSubject)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            // Fetch user data from users collection
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(data['studentId'])
                .get();
            if (userSnapshot.exists) {
              Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
              setState(() {
                _attendanceData.add({
                  'studentId': userData['studentId'] ?? '',
                  'subject': data['subject'] ?? '',
                  'timestamp': data['timestamp'] ?? '',
                  'date': data['date'] ?? '',
                  'time': data['time'] ?? '',
                  'firstName': userData['firstName'] ?? '',
                  'profilePicture': userData['profilePicture'] ?? '',
                });
              });
            }
          });
          setState(() {
            _isTableVisible = true;
          });
        }).catchError((error) {
          print('Error fetching attendance: $error');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
              SizedBox(height:4),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : ''),
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        labelStyle: TextStyle(color: Colors.teal),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                      ),
                      style: const TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Subject',
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
                  dropdownColor: Colors.teal,
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
                      _isTableVisible = false;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _filterData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
              ),
              if (_isTableVisible)
                Expanded(
                  child: ListView.builder(
                    itemCount: _attendanceData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              _attendanceData[index]['profilePicture']), // Replace with actual image URL
                        ),
                        title: Text(
                          _attendanceData[index]['firstName'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Student ID: ${_attendanceData[index]['studentId']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
