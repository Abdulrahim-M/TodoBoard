
import 'package:flutter/material.dart';

import '../constants/palette.dart' as clr;

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clr.background,
      body: Stack(
        children: [
          Placeholder(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Coming Soon", style: TextStyle(color: clr.textPrimary, fontSize: 30)),
                SizedBox(height: 20),
                Text("This feature is currently under development.", style: TextStyle(color: clr.textSecondary, fontSize: 15)),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
