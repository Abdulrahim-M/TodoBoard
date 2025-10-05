import 'package:flutter/material.dart';
import 'package:rpg_life_app/views/loading_view.dart';
import 'package:rpg_life_app/views/login_view.dart';

import 'package:rpg_life_app/views/mainapp_view.dart';
import 'package:rpg_life_app/views/register_view.dart';
import 'package:rpg_life_app/views/verify_email_view.dart';
import 'package:rpg_life_app/services/auth/auth_service.dart';

import 'constants/routes.dart';

const bool USE_EMULATOR = true;


void main(){
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 55, 255, 0),
          // brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        homeRoute: (context) => const HomePage(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    )
  );
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(USE_EMULATOR),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user == null || !user.isEmailVerified) {
                return LoginView();
              }
              else {
                return MainAppView();
              }
            default:
              return LoadingView();
          }
        } ,
      );
  }
}



