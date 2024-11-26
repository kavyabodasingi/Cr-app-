// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';

// class ManualAttendanceScreen extends StatefulWidget {
//   const ManualAttendanceScreen({Key? key}) : super(key: key);

//   @override
//   State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
// }

// class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
//   final List<String> subjects = [];
//   String? selectedSubject;
//   List<Map<String, dynamic>> studentsData = [];
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     fetchSubjectsAndStudents();
//     super.initState();
//   }

//   Future<void> fetchSubjectsAndStudents() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
//             .collection('admin')
//             .doc(user.uid)
//             .get();

//         String? currentUserName = userDoc['userName'];

//         // Fetch subjects from the admin document
//         if (userDoc.exists && userDoc.data() != null) {
//           List<dynamic>? fetchedSubjects = userDoc['subjects'];
//           if (fetchedSubjects != null) {
//             setState(() {
//               subjects.addAll(List<String>.from(fetchedSubjects));
//             });
//           }
//         }

//         // Fetch students
//         QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .where('userName', isEqualTo: currentUserName)
//             .get();

//         setState(() {
//           studentsData = snapshot.docs.map((doc) {
//             var data = doc.data();
//             data['uid'] = doc.id;
//             return data;
//           }).toList();

//           // Assign serial numbers to each student data
//           studentsData.asMap().forEach((index, student) {
//             student['serialNo'] = index + 1;
//           });

//           // Fetch last attendance timestamp for each student
//           Future.wait(studentsData.map((student) => _getLastAttendanceTimestamp(student)));
//         });
//       }
//     } catch (e) {
//       print('Error fetching subjects and students data: $e');
//     }
//   }

//   Future<void> _getLastAttendanceTimestamp(Map<String, dynamic> student) async {
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(student['uid'])
//           .get();

//       if (userDoc.exists) {
//         setState(() {
//           student['lastAttendanceTimestamp'] = userDoc['lastAttendanceTimestamp'];
//           student['attended'] = !canAttend(userDoc['lastAttendanceTimestamp']);
//         });
//       }
//     } catch (e) {
//       print('Error fetching last attendance timestamp: $e');
//     }
//   }

//   bool canAttend(Timestamp? lastAttendanceTimestamp) {
//     if (lastAttendanceTimestamp == null) {
//       return true;
//     }

//     DateTime lastAttendanceTime = lastAttendanceTimestamp.toDate();
//     DateTime currentTime = DateTime.now();

//     return currentTime.difference(lastAttendanceTime).inMinutes >= 5;
//   }

//   Future<void> addAttendance(Map<String, dynamic> student) async {
//     try {
//       if (selectedSubject != null) {
//         DateTime now = DateTime.now();
//         String formattedDate = DateFormat('yyyy-MM-dd').format(now);
//         String formattedTime = DateFormat('HH:mm:ss').format(now);

//         // Check if the student can attend
//         if (!canAttend(student['lastAttendanceTimestamp'])) {
//           Fluttertoast.showToast(
//             msg: "You have already attended $selectedSubject within the last 5 minutes",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.grey,
//             textColor: Colors.white,
//           );
//           return;
//         }

//         // Add attendance record
//         await FirebaseFirestore.instance.collection('attendance').add({
//           'date': formattedDate,
//           'studentId': student['uid'],
//           'subject': selectedSubject,
//           'time': formattedTime,
//           'timeStamp': now,
//         });

//         // Update student's attendance status in Firestore
//         await FirebaseFirestore.instance.collection('users').doc(student['uid']).update({
//           'lastAttendanceTimestamp': now,
//         });

//         // Update student's attendance status locally
//         setState(() {
//           student['attended'] = true;
//           student['lastAttendanceTimestamp'] = Timestamp.now();
//         });

//         // Update subject count in users collection
//         await updateSubjectCount(selectedSubject);

//         Fluttertoast.showToast(
//           msg: "Attendance added successfully",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       } else {
//         print('Subject not selected');
//       }
//     } catch (e) {
//       print('Error adding attendance: $e');
//     }
//   }

//   Future<void> updateSubjectCount(String? subject) async {
//     if (subject != null) {
//       for (var student in studentsData) {
//         if (student.containsKey(subject)) {
//           try {
//             int currentCount = student[subject] ?? 0;
//             await FirebaseFirestore.instance.collection('users').doc(student['uid']).update({
//               subject: currentCount + 1,
//             });
//             print('Updated $subject count for student ${student['uid']}');
//           } catch (e) {
//             print('Error updating $subject count: $e');
//           }
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manual Attendance'),
//         backgroundColor: const Color(0xffB81736),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double padding = constraints.maxWidth * 0.05;
//           double fontSizeSubTitle = constraints.maxWidth * 0.04;

//           return SingleChildScrollView(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xffB81736), Color(0xff281537)],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               padding: EdgeInsets.all(padding),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         labelText: 'Select Subject',
//                         labelStyle: TextStyle(color: Colors.white),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide(color: Colors.white),
//                         ),
//                         filled: true,
//                         fillColor: Colors.white.withOpacity(0.2),
//                       ),
//                       dropdownColor: Colors.grey[800],
//                       style: TextStyle(color: Colors.white),
//                       value: selectedSubject,
//                       items: subjects.map((String subject) {
//                         return DropdownMenuItem<String>(
//                           value: subject,
//                           child: Text(subject),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedSubject = newValue;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a subject';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: padding),
//                     if (selectedSubject != null)
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(10.0),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.5),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: DataTable(
//                             columnSpacing: padding * 0.5,
//                             horizontalMargin: padding * 0.5,
//                             columns: [
//                               DataColumn(
//                                 label: Text(
//                                   'SI No',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: fontSizeSubTitle,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: Text(
//                                   'Profile',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: fontSizeSubTitle,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: Text(
//                                   'ID No',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: fontSizeSubTitle,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: Text(
//                                   'Name',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: fontSizeSubTitle,
//                                   ),
//                                 ),
//                               ),
//                               DataColumn(
//                                 label: Text(
//                                   'Actions',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: fontSizeSubTitle,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                             rows: studentsData.map((student) {
//                               return DataRow(cells: [
//                                 DataCell(
//                                   Text(
//                                     student['serialNo'].toString(),
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   CircleAvatar(
//                                     backgroundImage: NetworkImage(student['profilePicture']),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   Text(
//                                     student['studentId'].toString(),
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   Text(
//                                     '${student['firstName']} ${student['lastName']}',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   Row(
//                                     children: [
//                                       ElevatedButton(
//                                         onPressed: student['attended']
//                                             ? null
//                                             : () {
//                                                 if (_formKey.currentState!.validate()) {
//                                                   addAttendance(student);
//                                                 }
//                                               },
//                                         child: Text(student['attended'] ? 'Attended' : 'Attend'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: student['attended'] ? Colors.grey : Colors.green,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ]);
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final List<String> subjects = [];
  String? selectedSubject;
  List<Map<String, dynamic>> studentsData = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchSubjectsAndStudents();
    super.initState();
  }

  Future<void> fetchSubjectsAndStudents() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .get();

        String? currentUserName = userDoc['userName'];

        // Fetch subjects from the admin document
        if (userDoc.exists && userDoc.data() != null) {
          List<dynamic>? fetchedSubjects = userDoc['subjects'];
          if (fetchedSubjects != null) {
            setState(() {
              subjects.addAll(List<String>.from(fetchedSubjects));
            });
          }
        }

        // Fetch students
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userName', isEqualTo: currentUserName)
            .get();

        setState(() {
          studentsData = snapshot.docs.map((doc) {
            var data = doc.data();
            data['uid'] = doc.id;
            return data;
          }).toList();

          // Assign serial numbers to each student data
          studentsData.asMap().forEach((index, student) {
            student['serialNo'] = index + 1;
          });

          // Fetch last attendance timestamp for each student
          Future.wait(studentsData.map((student) => _getLastAttendanceTimestamp(student)));
        });
      }
    } catch (e) {
      print('Error fetching subjects and students data: $e');
    }
  }

  Future<void> _getLastAttendanceTimestamp(Map<String, dynamic> student) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(student['uid'])
          .get();

      if (userDoc.exists) {
        setState(() {
          student['lastAttendanceTimestamp'] = userDoc['lastAttendanceTimestamp'];
          student['attended'] = !canAttend(userDoc['lastAttendanceTimestamp']);
        });
      }
    } catch (e) {
      print('Error fetching last attendance timestamp: $e');
    }
  }

  bool canAttend(Timestamp? lastAttendanceTimestamp) {
    if (lastAttendanceTimestamp == null) {
      return true;
    }

    DateTime lastAttendanceTime = lastAttendanceTimestamp.toDate();
    DateTime currentTime = DateTime.now();

    return currentTime.difference(lastAttendanceTime).inMinutes >= 5;
  }

  Future<void> addAttendance(Map<String, dynamic> student) async {
    try {
      if (selectedSubject != null) {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd').format(now);
        String formattedTime = DateFormat('HH:mm:ss').format(now);

        // Check if the student can attend
        if (!canAttend(student['lastAttendanceTimestamp'])) {
          Fluttertoast.showToast(
            msg: "You have already attended $selectedSubject within the last 5 minutes",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
          );
          return;
        }

        // Add attendance record
        await FirebaseFirestore.instance.collection('attendance').add({
          'date': formattedDate,
          'studentId': student['uid'],
          'subject': selectedSubject,
          'time': formattedTime,
          'timeStamp': now,
        });

        // Update student's attendance status in Firestore
        await FirebaseFirestore.instance.collection('users').doc(student['uid']).update({
          'lastAttendanceTimestamp': now,
        });

        // Update student's attendance status locally
        setState(() {
          student['attended'] = true;
          student['lastAttendanceTimestamp'] = Timestamp.now();
        });

        // Update subject count for this specific student
        await updateSubjectCount(selectedSubject, student['uid']);

        Fluttertoast.showToast(
          msg: "Attendance added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        print('Subject not selected');
      }
    } catch (e) {
      print('Error adding attendance: $e');
    }
  }

  Future<void> updateSubjectCount(String? subject, String studentId) async {
    if (subject != null) {
      try {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .get();

        if (studentDoc.exists) {
          Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;
          int currentCount = data[subject] ?? 0;
          await FirebaseFirestore.instance.collection('users').doc(studentId).update({
            subject: currentCount + 1,
          });
          print('Updated $subject count for student $studentId');
        }
      } catch (e) {
        print('Error updating $subject count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Attendance'),
        backgroundColor: const Color(0xffB81736),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth * 0.05;
          double fontSizeSubTitle = constraints.maxWidth * 0.04;

          return SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffB81736), Color(0xff281537)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Subject',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                      ),
                      dropdownColor: Colors.grey[800],
                      style: TextStyle(color: Colors.white),
                      value: selectedSubject,
                      items: subjects.map((String subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSubject = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a subject';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: padding),
                    if (selectedSubject != null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DataTable(
                            columnSpacing: padding * 0.5,
                            horizontalMargin: padding * 0.5,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'SI No',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeSubTitle,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeSubTitle,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ID No',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeSubTitle,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeSubTitle,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeSubTitle,
                                  ),
                                ),
                              ),
                            ],
                            rows: studentsData.map((student) {
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    student['serialNo'].toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(student['profilePicture']),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student['studentId'].toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${student['firstName']} ${student['lastName']}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: student['attended']
                                            ? null
                                            : () {
                                                if (_formKey.currentState!.validate()) {
                                                  addAttendance(student);
                                                }
                                              },
                                        child: Text(student['attended'] ? 'Attended' : 'Attend'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: student['attended'] ? Colors.grey : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
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
}