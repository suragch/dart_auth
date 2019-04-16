import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:dart_auth/helpers/user.dart';
import 'package:dart_auth/helpers/database.dart';
import 'package:string_validator/string_validator.dart';

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
    user.password = _hashPassword(user.password);

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
    final salt = AuthUtility.generateRandomSalt();
    final saltedPassword = salt + password;
    final bytes = utf8.encode(saltedPassword);
    final hash = sha256.convert(bytes);
    // store the salt with the hash
    return '$salt.$hash';
  }
}
