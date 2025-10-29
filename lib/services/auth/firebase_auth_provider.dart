import 'dart:developer' as dev;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import 'auth_user.dart';
import 'auth_provider.dart';
import 'auth_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {

  @override
  Future<AuthUser> createUser({required String email, required String password,}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthAuthException();
      }
    } catch (e){
      throw GenericAuthAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    user?.reload();
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch(e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw InvalidCredentialsAuthException();
      }
    } catch (e){
      throw GenericAuthAuthException();
    }
  }

  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize(bool useEmulator) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up the emulator for Firebase
    if(useEmulator) {
      if (!kIsWeb) {
        dev.log("Using emulator on ${Platform.isAndroid ? "Android" : "iOS or Desktop."}");
        final localHostString = Platform.isAndroid ? '10.0.2.2' : 'localhost'; //'10.0.2.2'

        FirebaseFirestore.instance.settings = Settings(
          host: '$localHostString:8080',
          sslEnabled: false,
          persistenceEnabled: false,
        );

        await FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);
      } else {
        dev.log("Using emulator on Web.");
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      }
    } else {
      dev.log("Using real Firebase, not emulator");
    }

    try {
      await FirebaseAuth.instance.currentUser?.reload();
    }
    catch (e) {
      FirebaseAuth.instance.signOut();
    }

  }

}