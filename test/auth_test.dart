import 'package:todo_board/services/auth/auth_exceptions.dart';
import 'package:todo_board/services/auth/auth_provider.dart';
import 'package:todo_board/services/auth/auth_service.dart';
import 'package:todo_board/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialised, false);
    });
    test('Cannot log out if not initialized', () {
      expect(() async => await provider.logout(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to initialize", () async {
      await provider.initialize(true);
      expect(provider.isInitialised, true);
    });
    test("User should be null", () {
      expect(provider._user, null);
    });
    test("Should be able to initialize in less that 2 seconds", () async {
      await provider.initialize(true);
      expect(provider.isInitialised, true);
    },
      timeout: const Timeout(const Duration(seconds: 2)),
    );
    test("Create user should delegate to login function", () async {
      expect(() async => await provider.createUser(email: "foo@bar.com", password: "foobaz"),
          throwsA(const TypeMatcher<UserNotFoundAuthException>())
      );

      expect(() async =>  await provider.createUser(email: "foot@bar.com", password: "foobar"),
          throwsA(const TypeMatcher<WrongPasswordAuthException>())
      );

      final user = await provider.createUser(email: "foo", password: "foo");
      expect(provider.currentUser, user);

      expect(user.isEmailVerified, false);
    });

    test("Logged in user should be able to get verified", () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to log out and log in again", () async {
      await provider.logout();
      await provider.login(email: "foo", password: "foo");
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });

}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  bool _isInitialised = false;
  bool get isInitialised => _isInitialised;

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if (!_isInitialised) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize(bool useEmulator) async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialised = true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!_isInitialised) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    final user = AuthUser(id: 'my_id', isEmailVerified: false, email: email, displayName: '', photoUrl: '', phoneNumber: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!_isInitialised) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialised) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    final newUser = AuthUser(id: 'my_id', isEmailVerified: true, email: user.email, displayName: '', photoUrl: '', phoneNumber: '');
    _user = newUser;
    return await Future.value(null);

  }
  
}