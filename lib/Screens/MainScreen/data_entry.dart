import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataEntry extends StatefulWidget {
  const DataEntry({super.key});

  @override
  State<DataEntry> createState() => _DataEntryState();
}

class _DataEntryState extends State<DataEntry> {
  final TextEditingController _subjectController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addSubject() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String subject = _subjectController.text.trim();
      if (subject.isNotEmpty) {
        final DocumentReference adminDoc =
            FirebaseFirestore.instance.collection('admin').doc(user.uid);

        // Update the admin document with the new subject as a field with a value of 0
        await adminDoc.update({
          'subjects': FieldValue.arrayUnion([subject]),
          subject: 0,
        });

        // Retrieve all documents from the 'users' collection
        final QuerySnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        if (userSnapshot.docs.isNotEmpty) {
          for (var doc in userSnapshot.docs) {
            // Update each user document by adding a new field for the subject
            await doc.reference.update({
              subject: 0,
            });
          }
        }

        _subjectController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject cannot be empty')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user signed in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Enter Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSubject,
              child: Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}
