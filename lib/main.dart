import 'package:flutter/material.dart';
import 'package:todo_board/services/crud/task_service.dart';
import 'package:todo_board/views/home.dart';
import 'package:todo_board/views/loading_view.dart';
import 'package:todo_board/views/Signing/login_view.dart';
import 'package:todo_board/views/notes/edit_note_view.dart';
import 'package:todo_board/views/profile_view.dart';
import 'package:todo_board/views/tasks/edit_task_view.dart';

import 'package:todo_board/views/Signing/register_view.dart';
import 'package:todo_board/views/Signing/verify_email_view.dart';
import 'package:todo_board/services/auth/auth_service.dart';

import 'package:todo_board/constants/routes.dart';

const bool USE_EMULATOR = true;


void main(){
  runApp(
    MaterialApp(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case editTaskRoute:
            final data = settings.arguments as Map<DatabaseTask?, bool>;
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EditTaskView(data: data),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Customize animation here — e.g., slide from bottom
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOut;

                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );

            case editNoteRoute:
            final data = settings.arguments as DatabaseNote?;
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => EditNoteView(data: data),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Customize animation here — e.g., slide from bottom
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOut;

                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );

          default:
            return MaterialPageRoute(builder: (context) => Wayfinder());
        }
      },

      title: 'TodoBoard',
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 55, 255, 0),
          // brightness: Brightness.dark,
        ),
      ),
      home: const Wayfinder(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        homeRoute: (context) => const Wayfinder(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        profileRoute: (context) => const ProfileView(),
      },
    )
  );
}


class Wayfinder extends StatelessWidget {
  const Wayfinder({super.key});

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
                return Home();
              }
            default:
              return LoadingView();
          }
        } ,
      );
  }
}



