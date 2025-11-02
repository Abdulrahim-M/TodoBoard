
import 'dart:developer' as dev;

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:todo_board/services/crud/task_service.dart';

import 'package:todo_board/constants/routes.dart';

import '../../constants/palette3.dart';

typedef TaskCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final TaskCallback pinNote;
  final TaskCallback deleteNote;

  const NotesListView({super.key, required this.notes, required this.pinNote, required this.deleteNote});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        notes.length, (index) {
          return
            Card(
                elevation: 4,
                margin: EdgeInsets.fromLTRB(15, 6, 15, 6),
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 5),
                  onTap: () => Navigator.of(context).pushNamed(
                      editNoteRoute,
                      arguments: notes[index]
                  ),
                  onLongPress: () {
                    pinNote(notes[index]);
                    print(notes[index].isPinned);
                  },
                  title: Text(
                    notes[index].name ,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Column(
                    children: [
                      Text(
                        notes[index].content,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 15,),
                      Row(
                        // spacing: 100,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                DateFormat('MMMM d').format(notes[index].createdAt),
                                style: Theme.of(context).textTheme.bodySmall
                            ),
                            SizedBox(width: 5,),
                            Icon(
                              color: notes[index].isPinned ? Colors.transparent : RColors.primary,
                              Icons.push_pin_outlined,
                              size: 15,
                            )
                          ]
                      )
                    ],
                  ),
                  style: ListTileStyle.drawer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            );
        }
      ),
    );
  }
}
