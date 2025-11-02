
import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Coming Soon", style: Theme.of(context).textTheme.headlineLarge),
                SizedBox(height: 20),
                Text("This feature is currently under development.", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
