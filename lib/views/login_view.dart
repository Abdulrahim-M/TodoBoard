
import 'package:flutter/material.dart';
import 'package:rpg_life_app/constants/routes.dart';
import 'package:rpg_life_app/views/verify_email_view.dart';
import 'package:rpg_life_app/services/auth/auth_service.dart';
import 'package:rpg_life_app/services/auth/auth_exceptions.dart';

import '../utilities/show_error_dialog.dart';

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

        body: Container(
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
                        await AuthService.firebase().login(
                            email: email,
                            password: password,
                        );
                      } on UserNotFoundAuthException catch (e) {
                        showErrorDialog(context, "User not found");
                        return;
                      } on WrongPasswordAuthException catch (e) {
                        showErrorDialog(context, "Wrong password",);
                        return;
                      } on InvalidCredentialsAuthException catch (e) {
                        showErrorDialog(context, "Invalid credentials",);
                        return;
                      } on GenericAuthAuthException catch (e) {
                        showErrorDialog(context, "Authentication error while logging in",);
                        return;
                      } catch (e) {
                        showErrorDialog(context, e.toString());
                        return;
                      }

                      final user = AuthService.firebase().currentUser;
                      if (user == null) {
                        setState(() {});
                      }
                      else if (!user.isEmailVerified) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const VerifyEmailView(),
                            ),
                          );
                        });
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
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
                            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
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

          )

    );
  }
}