import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:dart_auth/helpers/user.dart';
import 'package:dart_auth/helpers/database.dart';
import 'package:string_validator/string_validator.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SignupController extends ResourceController {
  @Operation.post()
  Future<Response> signup() async {
    // get user info from request body
    final map = await request.body.decode<Map<String, dynamic>>();
    final User user = User.fromJson(map);

    // check that username is email and password long enough
    if (!_isValid(user)) {
      return Response.badRequest();
    }

    // check if the user exists
    final Database database = MockDatabase();
    final User foundUser = database.queryEmail(user.email);
    if (foundUser != null) {
      return Response.forbidden();
    }

    // salt and hash the password
    final hash = _hashPassword(user.password);

    // add user to database
    user.id = database.addUser(user);

    // send a response
    return Response.ok('user added');
  }

  bool _isValid(User user) {
    if (user == null || user.email == null || user.password == null) {
      return false;
    }
    if (!isEmail(user.email)) {
      return false;
    }
    if (!isLength(user.password, 8)) {
      return false;
    }
    return true;
  }

  String _hashPassword(String password) {
    var password = 'password123';
var salt = 'UVocjgjgXg8P7zIsC93kKlRU8sPbTBhsAMFLnLUPDRYFIWAk';
var saltedPassword = salt + password;
var bytes = utf8.encode(saltedPassword);
var hash = sha256.convert(bytes);
  }
}
