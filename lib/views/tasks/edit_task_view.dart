
import 'package:flutter/material.dart';
import 'package:rpg_life_app/services/crud/task_service.dart';
import 'package:rpg_life_app/constants/palette.dart' as clr;
import 'package:rpg_life_app/views/coming_soon_view.dart';

import '../../utilities/dialogs/dialogs.dart';



class EditTaskView extends StatefulWidget {
  final Map<DatabaseTask?, bool> data;

  const EditTaskView({required this.data, super.key});

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  late final TasksService _tasksService;
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late final DatabaseTask? _task;
  late final bool _isNew;

  String _name = "";
  String _note = "";

  Future<DatabaseTask> _createTask(String name, String note) async {
    return await _tasksService.createTask(name: name, note: note);
  }

  Future<DatabaseTask> _updateTask(String name, String note) async {
    return await _tasksService.updateTask(task: _task!, name: name, note: note);
  }

  Future<void> _deleteTask() async {
    return await _tasksService.deleteTask(id: _task!.id);
  }

  @override
  void initState() {
    _tasksService = TasksService();
    _nameController = TextEditingController();
    _noteController = TextEditingController();
    _task = widget.data.keys.first;
    _isNew = widget.data.values.first;
    if (!_isNew) {
      _nameController.text = _task!.name;
      _noteController.text = _task.note;
      _name = _task.name;
      _note = _task.note;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _isChanged() {
    return _name != _nameController.text || _note != _noteController.text;
  }

  @override
  Widget build(BuildContext context) {

    return PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          else if (!_isChanged()) {
            Navigator.pop(context);
          }
          else {
            final bool shouldPop = await showExitWithoutSaveDialog(context);
            if (context.mounted && shouldPop) {
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
          backgroundColor: clr.background,
          appBar: AppBar(
            backgroundColor: clr.onPrimary,

            title: _isNew ?
            const Text("Create Task", style: TextStyle(color: clr.textPrimary),) :
            SizedBox.square(),

            actions: [
              !_isNew ?
              IconButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty){
                    if (await deleteTaskDialog(context)) {
                      _deleteTask();
                      Navigator.of(context).pop();
                    }
                  }
                },
                icon: Text("DELETE", style:
                TextStyle(
                  fontSize: 15,
                  color: clr.textSecondary,
                )),
              ) : SizedBox.square(),
              _isNew ?
              IconButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty){
                    _createTask(_nameController.text, _noteController.text);
                    Navigator.of(context).pop();
                  }
                },
                icon: Text("CREATE", style:
                TextStyle(
                  fontSize: 15,
                  color: clr.textSecondary,
                )),
              ) :
              IconButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && (_isNew ? true : _isChanged())){
                      _updateTask(_nameController.text, _noteController.text);
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Text("SAVE", style:
                  TextStyle(
                    fontSize: 15,
                    color: clr.textSecondary,
                  )),
                disabledColor: clr.textDisabled,

              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: clr.onPrimary,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    spacing: 20,
                    children: [
                      TextField(
                        controller: _nameController,
                        style: TextStyle(color: clr.textPrimary),
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(),
                          fillColor: clr.dialogBG,
                          filled: true,
                          label: Text("Task Title"),
                          labelStyle: TextStyle(color: clr.textSecondary),
                        ),
                        autofocus: true,
                      ),
                      TextField(
                        controller: _noteController,
                        style: TextStyle(color: clr.textPrimary),
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(),
                          fillColor: clr.dialogBG,
                          filled: true,
                          label: Text("Decoration"),
                          labelStyle: TextStyle(color: clr.textDisabled),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                      Card()
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 600,
                  child: ComingSoon()
                )
              ),
            ],
          ),
        )

    );
  }
}
