import 'package:flutter/material.dart';

import 'package:todo_board/constants/palette3.dart';


class RTextFieldTheme {
  RTextFieldTheme._();

  static final lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: RColors.neutral,
    suffixIconColor: RColors.neutral,
    fillColor: RColors.neutral[200],

    labelStyle: TextStyle().copyWith(color: RColors.neutral),
    hintStyle: TextStyle().copyWith(color: RColors.neutral),
    errorStyle: TextStyle().copyWith(color: RColors.error),
    floatingLabelStyle: TextStyle().copyWith(color: RColors.primary),
  );

  static final darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: RColors.neutral,
    suffixIconColor: RColors.neutral,
    fillColor: RColors.neutral[800],

    labelStyle: TextStyle().copyWith(color: RColors.neutral),
    hintStyle: TextStyle().copyWith(color: RColors.neutral),
    errorStyle: TextStyle().copyWith(color: RColors.error),
    floatingLabelStyle: TextStyle().copyWith(color: RColors.primary),);

}