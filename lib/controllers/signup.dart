import 'dart:async';
import 'package:aqueduct/aqueduct.dart';
import 'package:dart_auth/helpers/user.dart';
import 'package:dart_auth/helpers/database.dart';

class SignupController extends ResourceController {
  @Operation.post()
  Future<Response> signup() async {

    // get user info from request body
    final map = await request.body.decode<Map<String, dynamic>>();
    final User user = User.fromJson(map);

    // check if the user exists
    final Database database = MockDatabase();
    final User foundUser = database.queryEmail(user.email);
    if (foundUser != null) {
      return Response.forbidden();
    }

    // add user to database
    database.addUser(user);
    
    // send a response 
    return Response.ok('user added');
  }
}


