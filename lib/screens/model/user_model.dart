import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String dob;
  final String email;
  final String mobile;
  final String gender;
  final String imageUrl;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "dob": dob,
      "email": email,
      "mobile": mobile,
      "gender": gender,
      "imageUrl": imageUrl,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }
}