import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rpg_life_app/views/loading_view.dart';
import 'package:rpg_life_app/views/login_view.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rpg_life_app/views/mainapp_view.dart';
import 'package:rpg_life_app/views/register_view.dart';
import 'package:rpg_life_app/views/verify_email_view.dart';

const bool USE_EMULATOR = true;

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

void main(){
  WidgetsFlutterBinding.ensureInitialized();
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
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/home': (context) => HomePage(),
        '/verify-email': (context) => const VerifyEmailView(),
        // '/forgot-password': (context) => const ForgotPasswordView(),
        // '/reset-password': (context) => const ResetPasswordView(),
        // '/Welcome': (context) => const WelcomeView(),
      },
    )
  );
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              print(user);
              if (user == null || !user.emailVerified) {
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



