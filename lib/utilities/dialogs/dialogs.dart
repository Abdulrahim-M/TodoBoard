import 'package:flutter/material.dart';
import 'package:todo_board/utilities/dialogs/generic_dialog.dart';

import '../../constants/palette3.dart';

Future<bool> deleteTaskDialog(BuildContext context) async {
  return await showGenericDialog(
    context: context,
    title: "Are You Sure?",
    content: "Are you sure you want to delete task?",
    optionsBuilder: () => {
      'GO BACK': false,
      'DELETE': true,
    } ,
    dialogLevelColor: RColors.warning,
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
    dialogLevelColor: RColors.warning,
  ) ?? false;
}

enum DialogLevel { success, error, warning, info }

final Map<DialogLevel, Color> dialogLevelColors = {
  DialogLevel.success: RColors.success,
  DialogLevel.error: RColors.error,
  DialogLevel.warning: RColors.warning,
  DialogLevel.info: RColors.info,
};

Future<void> showErrorDialog(BuildContext context, String message, DialogLevel level) {
  return showGenericDialog(
    context: context,
    title: 'An error occurred',
    content: message,
    optionsBuilder: () => { 'OK' : null },
    dialogLevelColor: dialogLevelColors[level] ?? RColors.info,
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
    dialogLevelColor: RColors.warning,
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
    dialogLevelColor: RColors.error,
  ) ?? false;
}