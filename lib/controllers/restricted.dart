import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dart_auth/helpers/config.dart';

class RestrictedController extends ResourceController {
  @Operation.get()
  Future<Response> restricted(
      @Bind.header("authorization") String authHeader) async {
    // only allow requests with valid tokens
    if (!_isAuthorized(authHeader)) {
      return Response.forbidden();
    }

    // We are returning a string here, but this could be
    // a file or data from the database.
    return Response.ok('restricted resource');
  }

  // parse the auth header
  bool _isAuthorized(String authHeader) {
    final parts = authHeader.split(' ');
    if (parts == null || parts.length != 2 || parts[0] != 'Bearer') {
      return false;
    }
    return _isValidToken(parts[1]);
  }

  bool _isValidToken(String token) {
    const key = Properties.jwtSecret;
    try {
      verifyJwtHS256Signature(token, key);
      return true;
    } on JwtException {
      print('invalid token');
    }
    return false;
  }
}
