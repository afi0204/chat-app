import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName:
          map['displayName'] ?? map['email'] ?? '', // Fallback to email
      photoURL: map['photoURL'],
    );
  }
}
