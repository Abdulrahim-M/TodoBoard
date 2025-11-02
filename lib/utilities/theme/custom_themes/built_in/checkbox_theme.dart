import 'package:flutter/material.dart';

import 'package:todo_board/constants/palette3.dart';

class RCheckboxTheme {
  RCheckboxTheme._();

  static CheckboxThemeData lightTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((state) {
      if (state.contains(WidgetState.selected)) {
        return RColors.neutral[100];
      }
      return RColors.neutral[900];
    }),
    fillColor: WidgetStateProperty.resolveWith((state) {
      if (state.contains(WidgetState.selected)) {
        return RColors.primary;
      }
      return Colors.transparent;
    }),
  );

  static CheckboxThemeData darkTheme = CheckboxThemeData();

}
