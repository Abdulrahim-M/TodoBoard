import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../constants/palette3.dart';
import '../../services/crud/task_service.dart';
import '../../utilities/theme/custom_themes/markdown_theme.dart';
import '../../widgets/custom_markdown.dart';
import '../loading_view.dart';

class EditNoteView extends StatefulWidget {
  final DatabaseNote? data;

  const EditNoteView({required this.data, super.key});

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  late final TasksService _tasksService;
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  DatabaseNote? _note;

  bool _isPreview = false;
  String _noteText = "";
  String _name = "";
  String _content = "";

  final _characterCount = ValueNotifier<int>(0);

  @override
  void initState() {
    _tasksService = TasksService();
    _nameController = TextEditingController();
    _contentController = TextEditingController(text: _noteText)
      ..selection = TextSelection.fromPosition(
      TextPosition(offset: _noteText.length),
    );
    if (widget.data != null){
      _note = widget.data;
      _nameController.text = _note!.name;
      _contentController.text = _note!.content;
      _noteText = _note!.content;
      _name = _note!.name;
      _content = _note!.content;
      _characterCount.value = _note!.content.length;
    }

    super.initState();
  }

  Future<DatabaseNote> createNote() async {
    return _note = await _tasksService.createNote(name: _name, content: _content);
  }

  void _updateNote() {
      _tasksService.updateNote(note: _note!, name: _nameController.text, content: _contentController.text);
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

  bool _isNew() {
    return widget.data == null && _note == null;
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
          _tasksService.deleteNote(id: _note!.id);
          Navigator.pop(context);
        }
        else {
          Navigator.pop(context);
        }
      },
      child: FutureBuilder(
        future: _isNew() ? createNote() : null,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.none:
              return mainView();

            default:
              return LoadingView();
          }
        }
      ),
    );
  }

  Scaffold mainView () {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(_isPreview ? 'Preview' : 'Edit Note', style: Theme.of(context).textTheme.titleLarge),
            floating: true,
            pinned: true,

            actions: [
              IconButton(
                icon: _isPreview ? Icon(Icons.edit_note_outlined,) : Icon(Icons.remove_red_eye_outlined),
                onPressed: () {
                  _isPreview = !_isPreview;
                  setState(() {});
                }
              ),
              IconButton(
                icon: Icon(Icons.share_outlined,),
                onPressed: () {
                  // TODO: Share note
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert_outlined,),
                onPressed: () {
                  // TODO: More options
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "Title",
                        border: InputBorder.none,
                      ),
                      maxLines: 1,
                      onChanged: (name) => _updateNote(),
                    ),
                    dataRow(_characterCount)
                  ],
                )
            ),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: _isPreview
              ? RMarkdown(
                data: _noteText,
                selectable: true, // optional: let users select text
                styleSheet: RMarkdownTheme.theme(context),
              )
              : TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "Write something",
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: null,
                onChanged: (content) {
                  _updateNote();
                  _characterCount.value = content.length;
                  _noteText = content;
                }
              ),
            ),
          ),
        ],
      )
    );
  }

  ValueListenableBuilder dataRow(ValueNotifier<int> characterCount) {
    return ValueListenableBuilder(
        valueListenable: characterCount,
        builder: (context, value, child) {
          return Row(
            spacing: 10,
            children: [
              Text(DateFormat('MMM d, yyyy – hh:mm a').format(_note!.createdAt), style: Theme.of(context).textTheme.bodySmall,),
              Text("|", style: Theme.of(context).textTheme.bodySmall,),
              Text("$value Characters", style: Theme.of(context).textTheme.bodySmall,)
            ],
          );
        }
    );
  }
}



