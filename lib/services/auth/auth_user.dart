import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final String id;
  final bool isEmailVerified;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  const AuthUser({required this.displayName, required this.photoUrl, required this.phoneNumber, required this.id, required this.isEmailVerified, required this.email});

  factory AuthUser.fromFirebase(User user) => AuthUser(
      id: user.uid,
      isEmailVerified: user.emailVerified,
      email: user.email!,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber
  );


  @override
  String toString() {
    return 'AuthUser(id: $id, '
        'isEmailVerified: $isEmailVerified, '
        'email: $email, '
        'displayName: $displayName, '
        'photoUrl: $photoUrl, '
        'phoneNumber: $phoneNumber)';
  }

}