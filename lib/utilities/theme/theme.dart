import 'package:flutter/material.dart';
import 'package:todo_board/constants/palette3.dart';
import 'package:todo_board/utilities/theme/custom_themes/built_in/text_theme.dart';
import 'package:todo_board/utilities/theme/custom_themes/built_in/appbar_theme.dart';

import 'custom_themes/built_in/bottom_sheet_theme.dart';
import 'custom_themes/built_in/card_theme.dart';
import 'custom_themes/built_in/checkbox_theme.dart';
import 'custom_themes/built_in/chip_theme.dart';
import 'custom_themes/built_in/dialog_theme.dart';
import 'custom_themes/built_in/drawer_theme.dart';
import 'custom_themes/built_in/elevated_button_theme.dart';
import 'custom_themes/built_in/outlined_button_theme.dart';
import 'custom_themes/built_in/text_field_theme.dart';

class RAppTheme {
  RAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: '',
    brightness: Brightness.light,
    primaryColor: RColors.primary,
    scaffoldBackgroundColor: RColors.neutral[100],
    appBarTheme: RAppBarTheme.lightTheme,
    textTheme: RTextTheme.lightTheme,
    drawerTheme: RDrawerTheme.lightTheme,
    cardTheme: RCardTheme.lightTheme,
    dialogTheme: RDialogTheme.lightTheme,

    inputDecorationTheme: RTextFieldTheme.lightInputDecorationTheme,

    elevatedButtonTheme: RElevatedButtonTheme.lightTheme,
    bottomSheetTheme: RBottomSheetTheme.lightTheme,
    outlinedButtonTheme: ROutlinedButtomTheme.lightTheme,
    chipTheme: RChipTheme.lightTheme,
    checkboxTheme: RCheckboxTheme.lightTheme,




    // cardTheme: CardThemeData(
    //   color: RColors.neutral[100],
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(10)
    //   )
    // )

  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: '',
    brightness: Brightness.dark,
    primaryColor: RColors.primary,
    scaffoldBackgroundColor: RColors.neutral[900],
    appBarTheme: RAppBarTheme.darkTheme,
    textTheme: RTextTheme.darkTheme,
    elevatedButtonTheme: RElevatedButtonTheme.darkTheme ,
    bottomSheetTheme: RBottomSheetTheme.darkTheme,
    outlinedButtonTheme: ROutlinedButtomTheme.darkTheme,
    chipTheme: RChipTheme.darkTheme,
    checkboxTheme: RCheckboxTheme.darkTheme,
    inputDecorationTheme: RTextFieldTheme.darkInputDecorationTheme,
    drawerTheme: RDrawerTheme.darkTheme,
    cardTheme: RCardTheme.darkTheme,
    dialogTheme: RDialogTheme.darkTheme,

  );

}