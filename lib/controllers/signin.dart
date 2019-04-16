import 'dart:async';
import 'dart:convert';
import 'package:aqueduct/aqueduct.dart';
import 'package:dart_auth/helpers/user.dart';
import 'package:dart_auth/helpers/database.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dart_auth/helpers/config.dart';
import 'package:crypto/crypto.dart';

class SigninController extends ResourceController {
  @Operation.post()
  Future<Response> signin(
      @Bind.header("authorization") String authHeader) async {
    
    final user = parseUser(authHeader);

    // only allow with correct username and password
    if (!_isValidUsernameAndPassword(user)) {
      return Response.unauthorized();
    }

    // get the token
    final String token = _signToken(user);

    // send the token back to the user
    return Response.ok(token);
  }
}

// extract the username and password from the header
User parseUser(String authHeader) {
  final parts = authHeader.split(' ');
  if (parts == null || parts.length != 2 || parts[0] != 'Basic') {
    return null;
  }
  final String decoded = utf8.decode(base64.decode(parts[1]));
  final credentials = decoded.split(':');
  return User(credentials[0], credentials[1]);
}

// check username and password
bool _isValidUsernameAndPassword(User user) {
  if (user == null) {
    return false;
  }
  final Database database = MockDatabase();
  final User foundUser = database.queryEmail(user.email);
  return foundUser != null &&
      _passwordHashMatches(foundUser.password, user.password);
}

bool _passwordHashMatches(String saltHash, String password) {
  // previously saved password hash
  final parts = saltHash.split('.');
  final salt = parts[0];
  final savedHash = parts[1];

  // user submitted password hash
  final saltedPassword = salt + password;
  final bytes = utf8.encode(saltedPassword);
  final newHash = sha256.convert(bytes).toString();

  return savedHash == newHash;
}

String _signToken(User user) {
  final claimSet = JwtClaim(
      issuer: 'Dart Server',
      subject: '${user.id}',
      issuedAt: DateTime.now(),
      maxAge: const Duration(hours: 12));
  const String secret = Properties.jwtSecret;
  return issueJwtHS256(claimSet, secret);
}
