
import 'package:flutter/material.dart';
import 'package:rpg_life_app/views/Signing/verify_email_view.dart';

import 'package:rpg_life_app/constants/routes.dart';
import 'package:rpg_life_app/services/auth/auth_exceptions.dart';
import 'package:rpg_life_app/services/auth/auth_service.dart';

import '../../constants/palette.dart' as clr;
import '../../utilities/dialogs/dialogs.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordAgain;
  bool _obscureText = true;

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
        body: CustomScrollView(
          slivers: [

            SliverAppBar(
              pinned: true,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Register", style: TextStyle(color: Colors.black)),
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
                          hintText: "Email",
                          suffixIcon: Icon(Icons.email),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _password,
                        decoration: InputDecoration(
                          hintText: "Password",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                              )
                          ),
                        ),
                        obscureText: _obscureText,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                      TextField(
                        controller: _passwordAgain,
                        decoration: InputDecoration(
                          hintText: "Enter Password Again",
                        ),
                        obscureText: _obscureText,
                        enableSuggestions: false,
                        autocorrect: false,
                      ),
                      Text("Password requirements", style: TextStyle(fontSize: 12)),
                      Text(" 1. At least 8 characters\n"
                          " 2. At least one upper case and one lower case characters should be present\n"
                          " 3. At least one digit should be present\n"
                          " 4. At least one special character should be present\n",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_password.text != _passwordAgain.text) {
                            showErrorDialog(context, "Passwords do not match", clr.error);
                            setState(() {_password.clear(); _passwordAgain.clear();});
                          } else {
                            final email = _email.text;
                            final password = _password.text;
                            try {
                              await AuthService.firebase().createUser(
                                  email: email,
                                  password: password
                              );
                              AuthService.firebase().sendEmailVerification();
                            } on EmailAlreadyInUseAuthException catch (e) {
                              showErrorDialog(context, "Email already in use", clr.error);
                              return;
                            } on WeakPasswordAuthException catch (e) {
                              showErrorDialog(context, "Weak password", clr.error);
                              return;
                            } on InvalidEmailAuthException catch (e) {
                              showErrorDialog(context, "Invalid email", clr.error);
                              return;
                              // } on GenericAuthAuthException catch (e) {
                              //   showErrorDialog(context, "Authentication error while registering",);
                              //   return;
                            } catch (e) {
                              showErrorDialog(context, e.toString(), clr.error);
                              return;
                            }
                            final user = AuthService.firebase().currentUser;
                            if (user == null) {
                              setState(() {_password.clear(); _passwordAgain.clear();});
                            }
                            else{
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const VerifyEmailView(),
                                ),
                              );
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
                              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                            },
                            child: Text("Login here", style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ]
                ),
              ),
            )
          ],
        )
    );
  }
}