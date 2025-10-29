
import 'package:flutter/material.dart';
import 'package:todo_board/services/auth/auth_service.dart';
import 'package:todo_board/services/auth/auth_user.dart';

import '../constants/palette.dart' as clr;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final AuthService _authService;

  AuthUser get _user => _authService.currentUser!;

  @override
  void initState() {
    _authService = AuthService.firebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clr.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  backgroundColor: clr.background,
                  iconTheme: IconThemeData(
                    color: clr.textPrimary,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(top: 80.0, left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: clr.textDisabled,
                            child: Text(
                              _user.displayName?.toUpperCase() ?? '?',
                              style: TextStyle(
                                fontSize: 30,
                                color: clr.background,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user.displayName?.isNotEmpty == true
                                      ? _user.displayName!
                                      : _user.email,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: clr.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: clr.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // About Section
                        Text(
                          "About",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: clr.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.email),
                            title: Text(_user.email),
                          ),
                        ),
                        SizedBox(height: 10),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Logout'),
                            onTap: () {
                              _authService.logout();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login', (route) => false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Placeholder for larger screen (can be enhanced)
          return Center(
            child: Text(
              'Desktop view coming soon!',
              style: TextStyle(color: clr.textPrimary),
            ),
          );
        },
      ),
    );

  }
}
