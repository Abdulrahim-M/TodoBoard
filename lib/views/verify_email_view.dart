import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpg_life_app/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> with WidgetsBindingObserver {
  User? user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app resumes (e.g., from background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkEmailVerified();
    }
  }

  Future<void> _checkEmailVerified() async {
    await user?.reload(); // Refresh the user
    user = FirebaseAuth.instance.currentUser;

    if (user?.emailVerified ?? false) {
      // Navigate to home or success screen
      Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
    } else {
      // Still not verified, stay on the page or show a message
      setState(() {}); // update UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),

      body:
        Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.grey[200],
                shadowColor: Colors.green[300],

                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Text("Your Email ${user?.email ?? ''} is not verified. "
                      "lease Verify Your Email by pressing "
                      "the button below, then check your email inbox.",
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                print(user);
              },
              child: Text("Send email verification"),
            ),
          ]
        )
    );
  }
}