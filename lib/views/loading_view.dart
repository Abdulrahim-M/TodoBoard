
import 'package:flutter/material.dart';

import '../constants/palette.dart' as clr;

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clr.background,
      body: Center(
          child: CircularProgressIndicator()
      )
    );
  }
}
