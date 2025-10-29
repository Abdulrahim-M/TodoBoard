
import 'dart:developer' as dev;

import 'package:todo_board/constants/palette.dart' as clr;

import 'package:flutter/material.dart';
import 'package:todo_board/services/crud/task_service.dart';

import 'package:todo_board/constants/routes.dart';

typedef TaskCallback = void Function(DatabaseTask task);

class TasksListView extends StatelessWidget {
  final List<DatabaseTask> tasks;
  final TaskCallback toggleTask;
  final TaskCallback deleteTask;

  const TasksListView({super.key, required this.tasks, required this.toggleTask, required this.deleteTask});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        tasks.length, (index) {
          return
            Card(
                elevation: 4,
                margin: EdgeInsets.fromLTRB(15, 6, 15, 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                color:  clr.onPrimary,
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  title: Text(
                    tasks[index].name ,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( color: clr.textPrimary),
                  ),
                  subtitle: Text(
                    tasks[index].note,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( color: clr.textSecondary),
                  ),
                  leading: IconButton(
                    icon: Icon(
                        tasks[index].isCompleted ?
                        Icons.check_box_rounded :
                        Icons.check_box_outline_blank
                    ),
                    color: clr.textDisabled,
                    onPressed: () {
                      toggleTask(tasks[index]);
                    },
                  ),
                  trailing: !tasks[index].isCompleted ?
                  IconButton(
                    icon: Icon(Icons.edit_outlined),
                    color: clr.textDisabled,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          editTaskRoute,
                          arguments: {tasks[index]: false}
                      );
                    },
                  ) : IconButton(
                    icon: Icon(Icons.delete_outline),
                    color: clr.textDisabled,
                    onPressed: () {
                      deleteTask(tasks[index]);
                    },
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
