
import 'package:flutter/material.dart';
import 'package:todo_board/main.dart';
import 'package:todo_board/services/auth/auth_service.dart';
import 'package:todo_board/services/auth/auth_user.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final AuthService _authService;
  late final _user;

  // AuthUser get _user => _authService.currentUser!;

  @override
  void initState() {
    _authService = AuthService.firebase();
    if(SKIP_LOGIN){
      _user = AuthUser(displayName: 'Anon', photoUrl: 'https://www.shutterstock.com/image-vector/unknown-male-user-secret-identity-600nw-2055592583.jpg', phoneNumber: '+123 456 789 1011', id: "#id123", isEmailVerified: true, email: 'anonymous@localhost.com');
    } else {
      _user = _authService.currentUser!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  iconTheme: IconThemeData(
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(top: 80.0, left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: _user.photoUrl.isEmpty
                              ? Text(
                                _user.displayName?.toUpperCase() ?? '?',
                                style: Theme.of(context).textTheme.headlineMedium,
                              )
                              : CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(_user.photoUrl),
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
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _user.email,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                          style: Theme.of(context).textTheme.headlineMedium,
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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          );
        },
      ),
    );

  }
}
