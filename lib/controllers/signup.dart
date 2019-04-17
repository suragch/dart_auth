import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:dart_auth/helpers/user.dart';
import 'package:dart_auth/helpers/database.dart';
import 'package:string_validator/string_validator.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dart_auth/helpers/config.dart';

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
    database.addUser(user);

    // get the token
    final String token = _signToken(user);
    
    // send the token back to the user
    return Response.ok(token);
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

  // creates a JWT with the user ID, expires in 12 hours
  String _signToken(User user) {
    final claimSet = JwtClaim(
      issuer: 'Dart Server',
      subject: '${user.id}',
      issuedAt: DateTime.now(),
      maxAge: const Duration(hours: 12)
    );
    const String secret = Properties.jwtSecret;
    return issueJwtHS256(claimSet, secret);
  }
}
