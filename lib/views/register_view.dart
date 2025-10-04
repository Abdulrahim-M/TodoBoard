import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rpg_life_app/main.dart';

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

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordAgain;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordAgain = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordAgain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: const Text("Register", style: TextStyle(color: Colors.black)),
          // backgroundColor: Color.fromARGB(255, 40, 142, 255),
        ),

        body:
        FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return
                  Container(
                  // color: Colors.grey,
                  // alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 50),
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
                        TextField(
                          controller: _passwordAgain,
                          decoration: InputDecoration(
                            hintText: "Enter Password Again",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.password),
                          ),
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        Text("Password requirements", style: TextStyle(fontSize: 12)),
                        Text(" 1. At least 8 characters\n" +
                             " 2. At least one upper case and one lower case characters should be present\n" +
                             " 3. At least one digit should be present\n" +
                             " 4. At least one special character should be present\n",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_password.text != _passwordAgain.text) {
                              // TODO: Manage Passwords don't match
                              print("Passwords do not match");
                              return;
                            } else {
                              final email = _email.text;
                              final password = _password.text;
                              try {
                                final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: email,
                                    password: password
                                );
                                print(userCredential);
                              } on FirebaseAuthException catch (e) {
                                // TODO: Manage error codes and user hints
                                if (e.code == 'weak-password') {
                                  print('The password provided is too weak.');
                                } else if (e.code == 'email-already-in-use') {
                                  print('The account already exists for that email.');
                                } else if (e.code == 'invalid-email') {
                                  print('The email address is badly formatted.');
                                }
                                print(e.code);
                                print(e.message);
                              }
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                setState(() {});
                              }
                              else if (!user.emailVerified) {
                                Navigator.of(context).pushNamedAndRemoveUntil("/verify-email", (route) => false);
                              }
                              else {
                                Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
                              }
                            }
                          },
                          child: Text("Register", style: TextStyle(fontSize: 20)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?", style: TextStyle(fontSize: 12)),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                              },
                              child: Text("Login here", style: TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                      ]
                  ),
                );
              default:
                return Center(child: Text("Loading...", style: TextStyle(fontSize: 20)),);
            }
          } ,
        )
    );
  }
}