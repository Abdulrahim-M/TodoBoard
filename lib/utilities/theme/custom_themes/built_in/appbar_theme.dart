import 'package:flutter/material.dart';

import 'package:todo_board/constants/palette3.dart';

class RAppBarTheme {
  RAppBarTheme._();

  static AppBarTheme lightTheme = AppBarTheme(
    backgroundColor: RColors.neutral[100],
    elevation: 0,
    iconTheme: IconThemeData(color: RColors.primary),
    titleTextStyle: TextStyle(color: RColors.primary[400], fontSize: 25),
    scrolledUnderElevation: 0,
  );

  static AppBarTheme darkTheme = AppBarTheme(
    backgroundColor: RColors.neutral[900],
    elevation: 0,
    iconTheme: IconThemeData(color: RColors.primary),
    titleTextStyle: TextStyle(color: RColors.primary[400], fontSize: 25),
    scrolledUnderElevation: 0,
  );

}