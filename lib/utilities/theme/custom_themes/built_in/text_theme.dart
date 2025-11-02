import 'package:flutter/material.dart';

import 'package:todo_board/constants/palette3.dart';

class RTextTheme {
  RTextTheme._();

  static TextTheme lightTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.bold, color: RColors.neutral[800]),
    headlineMedium: TextStyle().copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: RColors.neutral[800]),
    headlineSmall: TextStyle().copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: RColors.neutral[800]),

    titleLarge: TextStyle().copyWith(fontSize: 25, fontWeight: FontWeight.w700, color: RColors.neutral[800]),
    titleMedium: TextStyle().copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: RColors.neutral[800]),
    titleSmall: TextStyle().copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: RColors.neutral[800]),

    bodyLarge: TextStyle().copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: RColors.neutral[800]),
    bodyMedium: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: RColors.neutral[800]),
    bodySmall: TextStyle().copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: RColors.neutral[800]),

    labelLarge: TextStyle().copyWith(fontSize: 18, fontWeight: FontWeight.normal, color: RColors.neutral[800]),
    labelMedium: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: RColors.neutral[800]),
    labelSmall: TextStyle().copyWith(fontSize: 10, fontWeight: FontWeight.normal, color: RColors.neutral[800]),
  );

  static TextTheme darkTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.bold, color: RColors.neutral[100]),
    headlineMedium: TextStyle().copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: RColors.neutral[100]),
    headlineSmall: TextStyle().copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: RColors.neutral[100]),

    titleLarge: TextStyle().copyWith(fontSize: 25, fontWeight: FontWeight.w700, color: RColors.neutral[100]),
    titleMedium: TextStyle().copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: RColors.neutral[100]),
    titleSmall: TextStyle().copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: RColors.neutral[100]),

    bodyLarge: TextStyle().copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: RColors.neutral[100]),
    bodyMedium: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: RColors.neutral[100]),
    bodySmall: TextStyle().copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: RColors.neutral[100]),

    labelLarge: TextStyle().copyWith(fontSize: 18, fontWeight: FontWeight.normal, color: RColors.neutral[100]),
    labelMedium: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: RColors.neutral[100]),
    labelSmall: TextStyle().copyWith(fontSize: 10, fontWeight: FontWeight.normal, color: RColors.neutral[100]),);

}