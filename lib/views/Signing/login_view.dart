
import 'package:flutter/material.dart';
import 'package:rpg_life_app/constants/routes.dart';
import 'package:rpg_life_app/views/Signing/verify_email_view.dart';
import 'package:rpg_life_app/services/auth/auth_service.dart';
import 'package:rpg_life_app/services/auth/auth_exceptions.dart';

import '../../constants/palette.dart' as clr;
import '../../utilities/dialogs/dialogs.dart';

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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Login", style: TextStyle(color: Colors.black)),
                centerTitle: true,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      TextField(
                        controller: _email,
                        decoration: InputDecoration(
                          label: Text("Email"),
                          hintText: "Type your email address",
                          suffixIcon: Icon(Icons.email),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _password,
                        decoration: InputDecoration(
                          label: Text("Password"),
                          hintText: "Type your password",
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
                            showErrorDialog(context, "User not found", clr.error);
                            return;
                          } on WrongPasswordAuthException catch (e) {
                            showErrorDialog(context, "Wrong password", clr.error);
                            return;
                          } on InvalidCredentialsAuthException catch (e) {
                            showErrorDialog(context, "Invalid credentials", clr.error);
                            return;
                          } on GenericAuthAuthException catch (e) {
                            showErrorDialog(context, "Authentication error while logging in", clr.error);
                            return;
                          } catch (e) {
                            showErrorDialog(context, e.toString(), clr.error);
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
              ),
            )
          ],
        )

    );
  }
}