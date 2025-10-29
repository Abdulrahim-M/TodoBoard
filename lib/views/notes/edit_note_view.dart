import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/crud/task_service.dart';

class EditNoteView extends StatefulWidget {
  final DatabaseNote? data;

  const EditNoteView({required this.data, super.key});

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

TextStyle faint (double size) {
  return TextStyle(
      color: Colors.grey.shade400,
      fontSize: size
  );
}

class _EditNoteViewState extends State<EditNoteView> {
  late final TasksService _tasksService;
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final DatabaseNote _note;

  String _name = "";
  String _content = "";

  @override
  void initState() {
    _tasksService = TasksService();
    _nameController = TextEditingController();
    _contentController = TextEditingController();
    if (widget.data == null){
      createNote();
    } else {
      _note = widget.data!;
      _nameController.text = _note.name;
      _contentController.text = _note.content;
      _name = _note.name;
      _content = _note.content;
    }

    super.initState();
  }

    Future<void> createNote() async {
      _note = await _tasksService.createNote(name: _name, content: _content);
    }

    void _updateNote() {
      _tasksService.updateNote(note: _note, name: _nameController.text, content: _contentController.text);
    }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool _isEmpty() {
    return _nameController.text == "" && _contentController.text == "";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        else if (_isEmpty()) {
          _tasksService.deleteNote(id: _note.id);
          Navigator.pop(context);
        }
        else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Note"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(70),
            child: Expanded(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hint: Text("Title"),
                        hintStyle: TextStyle(fontSize: 20),
                        border: InputBorder.none,
                      ),
                      maxLines: 1,
                      autofocus: true,
                      onChanged: (name) => _updateNote(),
                    ),
                    Row(
                      children: [
                        Text(DateFormat('MMM d, yyyy – hh:mm a').format(_note.createdAt), style: faint(8),),
                        Text(" | ", style: faint(8),),
                        Text("Something else", style: faint(8),)
                      ],
                    )
                  ],
                )
              ),
            )
          ),
        ),
        body: Column(
          children: [

            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                label: Text("Decoration"),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (name) => _updateNote(),
            ),
          ],
        ),
      ),
    );
  }
}
