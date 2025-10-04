import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        ),

        bottomNavigationBar: BottomAppBar(
            color: Colors.blueGrey[100],
            child: Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          },
                          child: const Text("Sign out", style: TextStyle(fontSize: 20, color: Colors.black),)
                      )
                    ]
                  ),
                  LinearProgressIndicator(),
                ]
            )
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