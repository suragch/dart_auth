
import 'package:dart_auth/helpers/user.dart';

abstract class Database {
  int addUser(User user);
  User queryEmail(String email);
}

class MockDatabase implements Database {

  // singleton
  factory MockDatabase(){ return _instance; }
  MockDatabase._privateConstructor();
  static final MockDatabase _instance = MockDatabase._privateConstructor();

  static final List<User> _users = [];

  @override
  int addUser(User user) {
    final id = _users.length;
    user.id = id;
    _users.add(user);
    return id;
  }

  @override
  User queryEmail(String email) {
    for (User user in _users) {
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }
}