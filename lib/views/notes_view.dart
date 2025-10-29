
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

enum MenuAction {
  makeTask,
  about,
  settings,
}

class TasksView extends StatefulWidget {
  final bool showCompleted;

  const TasksView({super.key, required this.showCompleted});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  late final TasksService _tasksService;
  late final AuthService _authService;
  late List<DatabaseTask> allTasks;
  late List<DatabaseTask> allNotes;

  final _completed = ValueNotifier<int>(0);
  final _total = ValueNotifier<int>(0);

  List<DatabaseTask> get completedTasks => allTasks.where((task) => task.isCompleted).toList();
  List<DatabaseTask> get uncompletedTasks => allTasks.where((task) => !task.isCompleted).toList();

  @override
  void initState() {
    _tasksService = TasksService();
    _authService = AuthService.firebase();
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
        title: const Text("Notes", style: TextStyle(color: clr.textPrimary),),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(editTaskRoute, arguments: {null: true});
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
                  child: Text('Create Note'),
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
                stream: _tasksService.tasksStream,
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        allTasks = snapshot.data as List<DatabaseTask>;
                        WidgetsBinding.instance.addPostFrameCallback((_){
                          _completed.value = completedTasks.length;
                          _total.value = allTasks.length;
                        });
                        List<DatabaseTask> tasks = widget.showCompleted ? completedTasks : uncompletedTasks;
                        return TasksListView(tasks: tasks, toggleTask: (DatabaseTask task) {
                          _tasksService.checkOrUncheckTask(task: task);
                        }, deleteTask: (DatabaseTask task) {
                          _tasksService.deleteTask(id: task.id);
                        });
                      } else {
                        return LoadingView();
                      }

                    default:
                      return Center(child: Text("Waiting for tasks...", style: TextStyle(color: clr.textPrimary)),);
                  }
                },
            ),
          ),
        ],
      ),
    );
  }
}
