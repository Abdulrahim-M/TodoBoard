import 'package:flutter/material.dart';
import 'dart:developer'as dev;

import '../constants/routes.dart';
import '../services/auth/auth_service.dart';

enum MenuAction {
  Account,
  Settings,
  About,
  SignOut
}
class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("RPG Life"),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                dev.log(value.toString());
                switch (value) {
                  case MenuAction.SignOut:
                    dev.log("Sign out");
                    switch (await showLogOutDialog(context)) {
                      case true:
                        AuthService.firebase().logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                      case false:
                        dev.log("Sign out cancelled");
                    }
                    throw UnimplementedError();
                  case MenuAction.Account:
                    dev.log("Account Details");
                    // TODO: Handle this case.
                    throw UnimplementedError();
                  case MenuAction.Settings:
                    dev.log("Settings");
                    // TODO: Handle this case.
                    throw UnimplementedError();
                  case MenuAction.About:
                    dev.log("About");
                    // TODO: Handle this case.
                    throw UnimplementedError();
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.Account,
                    child: Text('Account'),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.Settings,
                    child: Text('Settings'),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.About,
                    child: Text('About'),
                  ),
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.SignOut,
                    child: Text('Sign Out'),
                  ),
                ];
              },
            ),
          ],
        ),

        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Done", style: TextStyle(fontSize: 20, color: Colors.black),),

              ]
          ),
        )
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sign Out"),
          content: const Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Sign Out"),
            ),
          ],
        );
      }
  ).then((value) => value ?? false);
}