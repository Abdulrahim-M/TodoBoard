import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:flutter/material.dart';

import 'package:todo_board/services/crud/task_service.dart';
import 'package:todo_board/views/loading_view.dart';
import 'package:todo_board/views/tasks/tasks_view.dart';

import 'constants/palette3.dart';
import 'constants/routes.dart';
import 'main.dart';
import 'services/auth/auth_service.dart';
import 'views/notes/notes_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late final AuthService _authService;
  late final TasksService _tasksService;
  final PageController _pageController = PageController();
  late final String _email;
  late Future _tasksServiceFuture;
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    TasksView(),
    NotesView(),
  ];

  @override
  void initState() {
    _tasksService = TasksService();
    _authService = AuthService.firebase();

    if (SKIP_LOGIN) {
      _email = "email@mail.com";
    } else {
      _email = _authService.currentUser!.email;
    }

    _tasksServiceFuture = _tasksService.open(email: _email);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Called when app resumes (e.g., from background)
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _tasksServiceFuture,
      builder: (context, asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(

              drawer: Drawer(
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

              body: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                setState(() => _selectedIndex = index);
                },
                children: _pages, // list of your pages
              ),

              bottomNavigationBar: SalomonBottomBar(
                currentIndex: _selectedIndex,
                onTap: (i) {
                  setState(() => _selectedIndex = i);
                  _pageController.jumpToPage(i);
                },

                items: List.generate(2, (index) {
                  Color selectedColor = Theme.of(context).brightness == Brightness.dark
                      ? RColors.primary
                      : RColors.primary;

                  List<BarItem> taps = [
                    BarItem('Tasks', Icons.list_alt),
                    BarItem('Notes', Icons.note_alt_outlined),
                  ];

                  return SalomonBottomBarItem(
                    selectedColor: selectedColor,
                    unselectedColor: RColors.neutral,
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
        color: RColors.primary[900]
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              _authService.currentUser?.photoUrl != null
                ? _authService.currentUser!.photoUrl!
                : ""
            ),
            child: _authService.currentUser?.photoUrl!.isEmpty ?? false
                ? Text(
                  _authService.currentUser?.displayName?.toUpperCase() ?? '!',
                  style: Theme.of(context).textTheme.titleLarge,
                ) : SizedBox(),
          ),
          SizedBox(height: 20,),
          Text(
            _email,
            style: TextStyle(
              fontSize: 20,
              color: RColors.neutral[200]
            )
          ),
        ],
      ),
    );
  }

  ListTile _buildItem({required String title, required IconData icon, required GestureTapCallback onTap}) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}

class BarItem {
  final String title;
  final IconData icon;

  BarItem(this.title, this.icon);
}
