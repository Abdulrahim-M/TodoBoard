import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:flutter/material.dart';
import 'package:todo_board/constants/palette.dart' as clr;

import 'package:todo_board/services/crud/task_service.dart';
import 'package:todo_board/views/coming_soon_view.dart';
import 'package:todo_board/views/loading_view.dart';
import 'package:todo_board/views/tasks/tasks_view.dart';

import '../constants/routes.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/auth_user.dart';
import 'notes/notes_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late final AuthService _authService;
  late final TasksService _tasksService;
  late final String _email;
  late Future _tasksServiceFuture;
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    TasksView(showCompleted: false,),
    TasksView(showCompleted: true,),
    NotesView(),
  ];

  @override
  void initState() {
    _tasksService = TasksService();
    _authService = AuthService.firebase();
    _email = "email@mail.com";//_authService.currentUser!.email;
    _tasksServiceFuture = _tasksService.open(email: _email);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // Called when app resumes (e.g., from background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _tasksServiceFuture,
      builder: (context, asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
              backgroundColor: clr.background,
              drawer: Drawer(
                backgroundColor: clr.onPrimary,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeader(),
                    _buildItem(
                      title: "Tasks",
                      icon: Icons.list_alt,
                      onTap: () { Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false); },
                    ),
                    _buildItem(
                      title: "Notification",
                      icon: Icons.notifications,
                      onTap: () {},
                    ),
                    _buildItem(
                      title: "Profile",
                      icon: Icons.person,
                      onTap: () { Navigator.of(context).pushNamed(profileRoute);},
                    ),
                    _buildItem(
                        title: "Settings",
                        icon: Icons.settings,
                        onTap: () {},
                    ),
                  ],
                ),
              ),

              body: _pages[_selectedIndex],

              bottomNavigationBar: SalomonBottomBar(
                currentIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
                backgroundColor: clr.background,
                items: List.generate(3, (index) {
                  List<BarItem> taps = [
                    BarItem('Tasks', Icons.list_alt, clr.primary),
                    BarItem('Done', Icons.done_all, clr.secondary),
                    BarItem('Notes', Icons.note_alt_outlined, clr.warning),
                  ];

                  return SalomonBottomBarItem(
                    selectedColor: taps[index].color,
                    unselectedColor: clr.textDisabled,
                    icon: Icon(taps[index].icon),
                    title: Text(taps[index].title),
                  );
                }),
              ),

            );
          default:
            return LoadingView();
        }
      }
    );
  }

  DrawerHeader _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: clr.textInverted,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: clr.textDisabled,
            child: Text(
              _authService.currentUser?.displayName?.toUpperCase() ?? '?',
              style: TextStyle(
                fontSize: 30,
                color: clr.background,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Text(_email, style: TextStyle(color: clr.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  _buildItem({required String title, required IconData icon, required GestureTapCallback onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(color: clr.textPrimary),),
      leading: Icon(icon, color: clr.textPrimary,),
      onTap: onTap,
    );
  }
}

class BarItem {
  final String title;
  final IconData icon;
  final Color color;

  BarItem(this.title, this.icon, this.color);
}
