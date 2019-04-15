
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
    _users.add(user);
    return _users.length - 1;
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