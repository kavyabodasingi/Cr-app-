import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final String classCode;
  final double latitude;
  final double longitude;
  final double percentage;
  final String subject;
  final bool request;
  final double radius;
  final String userName;
  final String studentId;
  final List<String> subjects;

  UserModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.classCode,
    required this.latitude,
    required this.longitude,
    required this.percentage,
    required this.subject,
    required this.request,
    required this.radius,
    required this.userName,
    required this.studentId,
    required this.subjects,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return UserModel(
        id: document.id,
        studentId: data['studentId'] ?? '',
        firstName: data['firstName'] ?? '',
        email: data['email'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        profilePicture: data['profilePicture'] ?? '',
        classCode: data['classCode'] ?? '',
        latitude: data['latitude'] ?? 0.0,
        longitude: data['longitude'] ?? 0.0,
        percentage: data['percentage'] ?? 0.0,
        subject: data['subject'] ?? '',
        request: data['request'] ?? false,
        radius: data['radius'] ?? 0.0,
        userName: data['userName'] ?? '',
        subjects: List<String>.from(data['subjects'] ?? []),
      );
    } else {
      return UserModel(
        id: '',
        firstName: '',
        email: '',
        phoneNumber: '',
        profilePicture: '',
        classCode: '',
        latitude: 0.0,
        longitude: 0.0,
        percentage: 0.0,
        subject: '',
        request: false,
        radius: 0.0,
        userName: '',
        studentId: '',
        subjects: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'classCode': classCode,
      'latitude': latitude,
      'longitude': longitude,
      'percentage': percentage,
      'subject': subject,
      'request': request,
      'radius': radius,
      'studentId': studentId,
      'userName': userName,
      'subjects': subjects,
    };
  }
}
