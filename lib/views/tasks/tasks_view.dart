
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:todo_board/constants/routes.dart';
import 'package:todo_board/services/crud/task_service.dart';
import 'package:todo_board/views/loading_view.dart';
import 'package:todo_board/views/tasks/tasks_list_view.dart';
import 'package:todo_board/widgets/usage_details.dart';

import '../../constants/palette3.dart';

// TODO: fix the filter, currently there are too many classes involved without it even working


enum MenuAction {
  makeTask,
  about,
  settings,
}

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  late final TasksService _tasksService;
  TasksFilter? _tasksFilter;
  final _filter = Filter();
  TaskSorter? _sorter;
  final _completed = ValueNotifier<int>(0);
  final _total = ValueNotifier<int>(0);
  bool? showCompleted = false;

  // List<DatabaseTask> get completedTasks => allTasks.where((task) => task.isCompleted).toList();
  // List<DatabaseTask> get uncompletedTasks => allTasks.where((task) => !task.isCompleted).toList();

  @override
  void initState() {
    _tasksService = TasksService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: Icon(Icons.menu),
        ),
        title: Text("Tasks", style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          IconButton(
              onPressed: () async {
                showModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return AnimatedBuilder(
                        animation: _filter,
                        builder: (context, child) {
                          return Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // fits content
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Filter", style: Theme.of(context).textTheme.bodyMedium),
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _tasksFilter?.reset();
                                          });
                                        },
                                        child: Text("CLEAR", style: Theme.of(context).textTheme.bodyMedium)
                                    )
                                  ],
                                ),
                                CheckboxListTile(
                                  value: _filter.showCompleted,
                                  tristate: false,
                                  onChanged: (value) {
                                    setState(() {
                                      _filter.toggleCompleted(value!);
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  enabled: true,
                                  title: Text("Completed", style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          );
                        },
                    );
                  },
                );
                    
              }, 
              icon: Icon(Icons.filter_list)
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(editTaskRoute, arguments: {null: true});
              },
              icon: const Icon(Icons.add)
          ),
          PopupMenuButton<MenuAction>(
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
            child:
              UsageDetailsRow(completedTasks: _completed, totalTasks: _total).build(context)
          ),

          SliverToBoxAdapter(
            child: StreamBuilder(
                stream: _tasksService.tasksStream,
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        if (_tasksFilter?.showCompleted == null) {
                          _tasksFilter = TasksFilter(tasks: (snapshot.data as List<DatabaseTask>), filter: _filter);
                        }
                        _sorter ??= TaskSorter(tasks: _tasksFilter!.getFilteredTasks());

                        WidgetsBinding.instance.addPostFrameCallback((_){
                          _completed.value = _tasksFilter!.getCompletedTasks.length;
                          _total.value = _tasksFilter!.tasks.length;
                        });

                        List<DatabaseTask> filteredTasks = _tasksFilter!.getFilteredTasks();
                        filteredTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                        return TasksListView(
                          tasks: filteredTasks,
                          toggleTask: (DatabaseTask task) {
                            _tasksService.checkOrUncheckTask(task: task);
                          },
                          deleteTask: (DatabaseTask task) {
                            _tasksService.deleteTask(id: task.id);
                          }
                        );
                      } else {
                        return LoadingView();
                      }

                    default:
                      return Center(child: Text("Waiting for tasks...", style: Theme.of(context).textTheme.bodyLarge),);
                  }
                },
            ),
          ),
        ],
      ),
    );
  }
}

class TasksFilter {
  List<DatabaseTask> tasks;
  Filter filter;

  TasksFilter({required this.tasks, required this.filter});

  late bool? showCompleted = filter.showCompleted;

  List<DatabaseTask> getFilteredTasks () {
    if (showCompleted != null && showCompleted == true) {
      return tasks.where((task) => task.isCompleted).toList();
    }
    else {
      return tasks.where((task) => !task.isCompleted).toList();
    }
  }

  // bool toggleCompleted() => showCompleted = !showCompleted;
  // bool toggleUncompleted() => showUncompleted = !showUncompleted;

  void reset() {
    showCompleted = false;
    // showUncompleted = true;
  }

  List<DatabaseTask> get getCompletedTasks => tasks.where((task) => task.isCompleted).toList();
  List<DatabaseTask> get getUncompletedTasks => tasks.where((task) => !task.isCompleted).toList();

}

class TaskSorter {
  List<DatabaseTask> tasks;

  TaskSorter({required this.tasks});

  void aByDateCreated() => tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  void zByDateCreated() => tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void aByUpdatedAt() => tasks.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  void zByUpdatedAt() => tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  void aByIsCompleted() => tasks.sort((a, b) => a.isCompleted.compareTo(b.isCompleted));
  void zByIsCompleted() => tasks.sort((a, b) => b.isCompleted.compareTo(a.isCompleted));

  void aByName() => tasks.sort((a, b) => a.name.compareTo(b.name));
  void zByName() => tasks.sort((a, b) => b.name.compareTo(a.name));

}

extension on bool {
  int compareTo(bool other) {
    if (this == true && other == false) return 1;
    if (this == false && other == true) return -1;
    return 0;
  }
}

class Filter extends ChangeNotifier {
  bool showCompleted = false;

  void toggleCompleted(bool value) {
    showCompleted = value;
    notifyListeners();
  }

  void reset() {
    showCompleted = false;
    notifyListeners();
  }
}
