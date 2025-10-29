
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:todo_board/constants/palette.dart' as clr;
import 'package:todo_board/constants/routes.dart';
import 'package:todo_board/services/crud/task_service.dart';
import 'package:todo_board/utilities/dialogs/dialogs.dart';
import 'package:todo_board/views/loading_view.dart';
import 'package:todo_board/views/tasks/tasks_list_view.dart';
import 'package:todo_board/widgets/usage_details.dart';

import '../../services/auth/auth_service.dart';
import 'notes_list_view.dart';

enum MenuAction {
  makeTask,
  about,
  settings,
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final TasksService _tasksService;
  late List<DatabaseNote> allNotes;

  @override
  void initState() {
    _tasksService = TasksService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clr.background,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: clr.textPrimary,
        ),
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu, color: clr.textPrimary),
        ),
        backgroundColor: clr.background,
        title: const Text("Tasks", style: TextStyle(color: clr.textPrimary),),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(editNoteRoute, arguments: null);
              },
              color: clr.secondary,
              icon: const Icon(Icons.add)
          ),
          PopupMenuButton<MenuAction>(
            iconColor: clr.secondary,
            onSelected: (value) async {
              switch (value) {
                case MenuAction.makeTask:
                  WidgetsBinding.instance.addPostFrameCallback((_){
                    Navigator.of(context).pushNamed(editTaskRoute, arguments: {null: true});
                  });
                case MenuAction.settings:
                  dev.log("Settings");
                  // TODO: Handle this case.
                  throw UnimplementedError();
                case MenuAction.about:
                  dev.log("About");
                  return showAboutDialog(
                      context: context,
                      applicationName: "Simple Tasks",
                      applicationVersion: "1.0.0-beta",
                      applicationIcon: const Icon(Icons.android),
                      applicationLegalese: "© 2025 RADGIT"
                  );
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.makeTask,
                  child: Text('Create Task'),
                ),
                PopupMenuItem<MenuAction>(
                  value: MenuAction.settings,
                  child: Text('Settings'),
                ),
                PopupMenuItem<MenuAction>(
                  value: MenuAction.about,
                  child: Text('About'),
                ),
              ];
            },
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: StreamBuilder(
                stream: _tasksService.notesStream,
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(notes: allNotes, pinNote: (DatabaseNote note) {
                          _tasksService.pinOrUnpinNote(note: note);
                        }, deleteNote: (DatabaseNote note) {
                          _tasksService.deleteTask(id: note.id);
                        });
                      } else {
                        return LoadingView();
                      }

                    default:
                      return Center(child: Text("Waiting for notes...", style: TextStyle(color: clr.textPrimary)),);
                  }
                },
            ),
          ),
        ],
      ),
    );
  }
}
