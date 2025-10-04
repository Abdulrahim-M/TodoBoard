import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rpg_life_app/main.dart';
import 'package:rpg_life_app/views/register_view.dart';
import 'package:rpg_life_app/views/verify_email_view.dart';

Future<FirebaseApp> _initializeFirebase() async {
  FirebaseApp firebaseApp = await Firebase.initializeApp();

  // Set up the emulator for Firebase
  if(USE_EMULATOR) {
    final localHostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';

    FirebaseFirestore.instance.settings = Settings(
      host: '$localHostString:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );

    await FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);
  }

  await FirebaseAuth.instance.currentUser?.reload();

  return firebaseApp;
}

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login", style: TextStyle(color: Colors.black)),
        ),

        body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Container(
                // color: Colors.grey,
                // alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      TextField(
                        controller: _email,
                        decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.email),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _password,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.password),
                        ),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                email: email,
                                password: password
                            );
                          } on FirebaseAuthException catch (e) {
                            // TODO: Manage error codes and user hints
                            if (e.code == "user-not-found") {
                              print("No user found for that email");
                              return null;
                            } else if (e.code == "wrong-password") {
                              print("Wrong password provided for that user");
                              return null;
                            }
                            print("Error caught");
                            print(e.code);
                            print(e.message);
                            return null;
                          }
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            setState(() {});
                          }
                          else if (!user.emailVerified) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (
                                      context) => const VerifyEmailView(),
                                ),
                              );
                            });
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
                            });
                          }
                        },
                        child: Text("Login", style: TextStyle(fontSize: 20)),
                      ),
                      // Forget password setup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Not registered yet?", style: TextStyle(
                              fontSize: 12, color: Colors.blueGrey)),
                          TextButton(
                            onPressed: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
                              });
                            },
                            child: Text(
                                "Register now",
                                style: TextStyle(fontSize: 12)),
                          )
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Forgot password functionality
                          // final user = FirebaseAuth.instance.currentUser;
                          // if (user != null) {
                          //   FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                          // }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).maybePop();
                          });
                        },
                        child: Text(
                            "Forgot password?",
                            style: TextStyle(fontSize: 12)),
                      )
                    ]
                ),

              );

            default:
              return Center(child: Text("Loading...", style: TextStyle(fontSize: 20)),);
          }
        }
    )
    );
  }
}
