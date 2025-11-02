import 'package:flutter/material.dart';

import '../../constants/palette3.dart' as clr;

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T> ({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
  required Color dialogLevelColor,
}){
  final options = optionsBuilder();
  
  return showDialog<T>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: dialogLevelColor, // Border color
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options.entries.map((entry) {
                    return TextButton(
                      onPressed: () => Navigator.of(context).pop(entry.value),
                      child: Text(entry.key),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );

        //   Container(
        //   decoration: BoxDecoration(
        //     border: Border.all(color: clr.border),
        //   ),
        //   child: AlertDialog(
        //     title: Text(title),
        //     content: Text(content),
        //     backgroundColor: clr.dialogBG,
        //     titleTextStyle: TextStyle(color: clr.textPrimary),
        //     contentTextStyle: TextStyle(color: clr.textSecondary),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        //     elevation: 5,
        //     shadowColor: Colors.black,
        //     actionsAlignment: MainAxisAlignment.center,
        //
        //     actions: options.keys.map((optionTitle) {
        //       final value = options[optionTitle];
        //       return TextButton(
        //           onPressed: () {
        //             if (value != null) {
        //               Navigator.of(context).pop(value);
        //             } else {
        //               Navigator.of(context).pop();
        //             }
        //           },
        //           child: Text(optionTitle)
        //       );
        //     }).toList()
        //   )
        // );
      }
  );
}