import 'package:flutter/material.dart';
import 'package:rpg_life_app/utilities/dialogs/generic_dialog.dart';

import '../../constants/palette.dart' as clr;

Future<bool> deleteTaskDialog(BuildContext context) async {
  return await showGenericDialog(
    context: context,
    title: "Are You Sure?",
    content: "Are you sure you want to delete task?",
    optionsBuilder: () => {
      'GO BACK': false,
      'DELETE': true,
    } ,
    dialogLevelColor: clr.warning,
  ) ?? false;
}

Future<bool> showLogOutDialog(BuildContext context) async {
  return await showGenericDialog<bool>(
      context: context,
      title: "Sign Out",
      content: "Are you sure you want to sign out?",
      optionsBuilder: () => {
        'CANCEL': false,
        'SIGN OUT': true,
      } ,
    dialogLevelColor: clr.warning,
  ) ?? false;
}

Future<void> showErrorDialog(BuildContext context, String message, Color level) {
  return showGenericDialog(
    context: context,
    title: 'An error occurred',
    content: message,
    optionsBuilder: () => { 'OK' : null },
    dialogLevelColor: level,
  );

}

Future<bool> showExitWithoutSaveDialog(BuildContext context) async {
  return await showGenericDialog(
    context: context,
    title: 'Are you sure?',
    content: "Are you sure you want to discard changes?",
    optionsBuilder: () => {
      'GO BACK': false,
      'DISCARD': true,
    } ,
    dialogLevelColor: clr.warning,
  ) ?? false;

}

Future<bool> showDeleteAllDialog(BuildContext context) async {
  return await showGenericDialog(
    context: context,
    title: 'Are you sure?',
    content: "This will delete all Completed tasks",
    optionsBuilder: () => {
      'GO BACK': false,
      'CONTINUE': true,
    } ,
    dialogLevelColor: clr.error,
  ) ?? false;
}