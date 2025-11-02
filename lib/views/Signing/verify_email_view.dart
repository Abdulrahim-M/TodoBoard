import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:todo_board/constants/routes.dart';

import '../../utilities/dialogs/dialogs.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_user.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> with WidgetsBindingObserver {
  late AuthUser user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user = AuthService.firebase().currentUser!;
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
    user = AuthService.firebase().currentUser!;

    if (user.isEmailVerified) {
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

      body: Container(
        alignment: Alignment.center,
        child: Column(
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
                  child: Text("An Email Verification was sent to ${user?.email ?? ''}"
                      "\nPlease check your email inbox and verify your email",
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () async {
                try {
                  AuthService.firebase().sendEmailVerification();
                } on GenericAuthAuthException catch (e) {
                  showErrorDialog(context, "Authentication error while registering", DialogLevel.error);
                  return;
                } catch (e) {
                  showErrorDialog(context, e.toString(), DialogLevel.error);
                  return;
                }
              },
              child: Text("Send email verification again"),
            ),
          ]
        ))
    );
  }
}