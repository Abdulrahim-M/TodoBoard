
import 'dart:developer' as dev;

import 'package:todo_board/constants/palette.dart' as clr;

import 'package:flutter/material.dart';
import 'package:todo_board/services/crud/task_service.dart';

import 'package:todo_board/constants/routes.dart';

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                color:  clr.onPrimary,
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  onTap: () => Navigator.of(context).pushNamed(
                      editNoteRoute,
                      arguments: notes[index]
                  ),
                  title: Text(
                    notes[index].name ,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( color: clr.textPrimary),
                  ),
                  subtitle: Text(
                    notes[index].content,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( color: clr.textSecondary),
                  ),
                  style: ListTileStyle.drawer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
            );
        }
      ),
    );
  }
}
