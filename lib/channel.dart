import 'package:dart_auth/controllers/signup.dart';
import 'package:dart_auth/controllers/signin.dart';
import 'package:dart_auth/controllers/restricted.dart';
import 'dart_auth.dart';

class DartAuthChannel extends ApplicationChannel {

  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router
      .route('/signup') 
      .link(() => SignupController()); 

    router
      .route('/signin') 
      .link(() => SigninController()); 

    router
      .route('/restricted') 
      .link(() => RestrictedController()); 

    return router;
  }
}