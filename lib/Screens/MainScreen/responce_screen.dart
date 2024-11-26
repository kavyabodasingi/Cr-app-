// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cr_admin/Screens/MainScreen/main_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ResponseScreen extends StatefulWidget {
//   const ResponseScreen({Key? key}) : super(key: key);

//   @override
//   _ResponseScreenState createState() => _ResponseScreenState();
// }

// class _ResponseScreenState extends State<ResponseScreen> {
//   Timer? _timer;
//   int _start = 60; // Timer starts from 60 seconds
//   bool _isStopButtonEnabled = true; // Always enable initially
//   String? selectedSubject; // Store the selected subject
//   int? _subjectValue; // Store the subject value

//   @override
//   void initState() {
//     super.initState();
//     _fetchSubjectData(); // Fetch the subject data on initialization
//     _startTimer();
//   }

//   Future<void> _fetchSubjectData() async {
//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('admin')
//           .doc(userId)
//           .get();
//       setState(() {
//         selectedSubject = userDoc.get('subject');
//         _subjectValue = userDoc.get(selectedSubject!);
//       });
//     } catch (e) {
//       print('Error fetching subject data: $e');
//     }
//   }

//   void _startTimer() {
//     const oneSec = Duration(seconds: 1);
//     _timer = Timer.periodic(
//       oneSec,
//       (Timer timer) {
//         if (_start == 0) {
//           setState(() {
//             _isStopButtonEnabled = true; // Enable stop button when timer ends
//             timer.cancel();
//             // Check if no requests were reached
//             if (_subjectValue != null) {
//               _decrementSubjectValue();
//             }
//           });
//         } else {
//           setState(() {
//             _start--;
//           });
//         }
//       },
//     );
//   }

//   Future<void> _decrementSubjectValue() async {
//     try {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       DocumentReference userDocRef = FirebaseFirestore.instance
//           .collection('admin')
//           .doc(userId);

//       await userDocRef.update({
//         selectedSubject!: FieldValue.increment(-1),
//       });

//       print('Subject value decremented');
//     } catch (e) {
//       print('Error decrementing subject value: $e');
//     }
//   }

//   Future<void> updateRequestStatusToFalse() async {
//     try {
//       // Get the current user's ID
//       String userId = FirebaseAuth.instance.currentUser!.uid;

//       // Create a reference to the user's document in Firestore
//       DocumentReference userDocRef =
//           FirebaseFirestore.instance.collection('admin').doc(userId);

//       // Update the request field in the document
//       await userDocRef.update({
//         'request': false,
//       });

//       print('Request status updated to false');
//     } catch (e) {
//       print('Error updating request status: $e');
//     }
//   }

//   void handleCancel(int index) {
//     // Handle the cancel action here
//     print('Cancel pressed for entry $index');
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Stream<List<Map<String, dynamic>>> getRecentAttendance() {
//     return FirebaseFirestore.instance
//         .collection('attendance')
//         .snapshots()
//         .asyncMap((snapshot) async {
//       List<Map<String, dynamic>> attendanceList = [];
//       for (var doc in snapshot.docs) {
//         var data = doc.data();
//         var timestamp = data['timestamp'] as Timestamp;
//         var now = DateTime.now();
//         var diff = now.difference(timestamp.toDate());
//         if (diff.inMinutes <= 5) {
//           var userId = data['studentId'];
//           var userDoc = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userId)
//               .get();
//           var userData = userDoc.data();
//           if (userData != null) {
//             attendanceList.add({
//               'id': doc.id,
//               'studentId': userId,
//               'firstName': userData['firstName'],
//               'date': data['date'],
//               'time': data['time'],
//             });
//           }
//         }
//       }
//       return attendanceList;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false, // Disable back button
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: const Text('Response Screen'),
//           backgroundColor: Colors.white,
//         ),
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF1C1C1C), Color(0xFF2C2C2C)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 color: Colors.black54,
//                 padding: const EdgeInsets.all(16.0),
//                 width: double.infinity,
//                 child: Column(
//                   children: [
//                     Text(
//                       'Time remaining: $_start seconds',
//                       style: const TextStyle(fontSize: 18, color: Colors.tealAccent),
//                     ),
//                     if (selectedSubject != null) // Display selected subject
//                       Text(
//                         'Subject: $selectedSubject',
//                         style: const TextStyle(fontSize: 18, color: Colors.tealAccent),
//                       ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _isStopButtonEnabled
//                           ? () {
//                               updateRequestStatusToFalse();
//                               Get.offAll(() => MainScreen());
//                             }
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                         backgroundColor: _isStopButtonEnabled ? Colors.red : Colors.grey,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: const Text(
//                         'Stop',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: StreamBuilder<List<Map<String, dynamic>>>(
//                   stream: getRecentAttendance(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(child: CircularProgressIndicator());
//                     }

//                     List<Map<String, dynamic>> attendanceList = snapshot.data!;

//                     return SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: DataTable(
//                           columns: const [
//                             DataColumn(
//                               label: Text('Serial No', style: TextStyle(color: Colors.tealAccent)),
//                             ),
//                             DataColumn(
//                               label: Text('Name', style: TextStyle(color: Colors.tealAccent)),
//                             ),
//                             DataColumn(
//                               label: Text('Time', style: TextStyle(color: Colors.tealAccent)),
//                             ),
//                             DataColumn(
//                               label: Text('Actions', style: TextStyle(color: Colors.tealAccent)),
//                             ),
//                           ],
//                           rows: List.generate(attendanceList.length, (index) {
//                             var attendance = attendanceList[index];
//                             return DataRow(
//                               cells: [
//                                 DataCell(Text('${index + 1}', style: const TextStyle(color: Colors.white))),
//                                 DataCell(Text(attendance['firstName'], style: const TextStyle(color: Colors.white))),
//                                 DataCell(Text(attendance['time'], style: const TextStyle(color: Colors.white))),
//                                 DataCell(Row(
//                                   children: [
//                                     ElevatedButton(
//                                       onPressed: _isStopButtonEnabled
//                                           ? () {
//                                               // Handle attend action
//                                               print('Attend pressed for entry $index');
//                                             }
//                                           : null,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.green,
//                                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                       ),
//                                       child: const Text('Attend'),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     ElevatedButton(
//                                       onPressed: () => handleCancel(index),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.red,
//                                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                       ),
//                                       child: const Text('Cancel'),
//                                     ),
//                                   ],
//                                 )),
//                               ],
//                             );
//                           }),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_admin/Screens/MainScreen/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponseScreen extends StatefulWidget {
  final selectedSubject;
  const ResponseScreen({Key? key, this.selectedSubject}) : super(key: key);

  @override
  _ResponseScreenState createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  Timer? _timer;
  bool hasRecentResponses = false;
  int _start = 60; // Timer starts from 60 seconds
  bool _isStopButtonEnabled = true; // Always enable initially

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _isStopButtonEnabled = true; // Enable stop button when timer ends
            timer.cancel();
            // Check if no requests were reached
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _decrementSubjectValue() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('admin').doc(userId);

      await userDocRef.update({
        widget.selectedSubject!: FieldValue.increment(-1),
      });

      print('Subject value decremented');
    } catch (e) {
      print('Error decrementing subject value: $e');
    }
  }

  Future<void> updateRequestStatusToFalse() async {
    try {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Create a reference to the user's document in Firestore
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('admin').doc(userId);

      // If no recent responses, decrement the subject value
      if (!hasRecentResponses) {
        await _decrementSubjectValue();
      }

      // Update the request field in the document
      await userDocRef.update({
        'request': false,
      });

      print('Request status updated to false');
    } catch (e) {
      print('Error updating request status: $e');
    }
  }

  void handleCancel(int index) {
    // Handle the cancel action here
    print('Cancel pressed for entry $index');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> getRecentAttendance() {
    return FirebaseFirestore.instance
        .collection('attendance')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> attendanceList = [];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        var timestamp = data['timestamp'] as Timestamp;
        var now = DateTime.now();
        var diff = now.difference(timestamp.toDate());
        if (diff.inMinutes <= 5) {
          var userId = data['studentId'];
          var userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          var userData = userDoc.data();
          if (userData != null) {
            attendanceList.add({
              'id': doc.id,
              'studentId': userId,
              'firstName': userData['firstName'],
              'date': data['date'],
              'time': data['time'],
            });
          }
        }
      }
      return attendanceList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Response Screen'),
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C1C1C), Color(0xFF2C2C2C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      'Time remaining: $_start seconds',
                      style: const TextStyle(
                          fontSize: 18, color: Colors.tealAccent),
                    ),
                    if (widget.selectedSubject !=
                        null) // Display selected subject
                      Text(
                        'Subject: ${widget.selectedSubject}',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.tealAccent),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isStopButtonEnabled
                          ? () async {
                              await updateRequestStatusToFalse();
                              Get.offAll(() => MainScreen());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        backgroundColor:
                            _isStopButtonEnabled ? Colors.red : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Stop',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getRecentAttendance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    // setState(() {
                    print("karunakar sankar bhuvi");
                      
                    // });
                    List<Map<String, dynamic>> attendanceList = snapshot.data!;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text('Serial No',
                                  style: TextStyle(color: Colors.tealAccent)),
                            ),
                            DataColumn(
                              label: Text('Name',
                                  style: TextStyle(color: Colors.tealAccent)),
                            ),
                            DataColumn(
                              label: Text('Time',
                                  style: TextStyle(color: Colors.tealAccent)),
                            ),
                            DataColumn(
                              label: Text('Actions',
                                  style: TextStyle(color: Colors.tealAccent)),
                            ),
                          ],
                          rows: List.generate(attendanceList.length, (index) {
                            print("Attendance Length ${attendanceList.length}");
                            hasRecentResponses = true;
                            var attendance = attendanceList[index];
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}',
                                    style:
                                        const TextStyle(color: Colors.white))),
                                DataCell(Text(attendance['firstName'],
                                    style:
                                        const TextStyle(color: Colors.white))),
                                DataCell(Text(attendance['time'],
                                    style:
                                        const TextStyle(color: Colors.white))),
                                DataCell(Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: _isStopButtonEnabled
                                          ? () {
                                              // Handle attend action
                                              print(
                                                  'Attend pressed for entry $index');
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Attend'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => handleCancel(index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }),
                        ),
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
