class User {
  User(this.email, this.password);

  factory User.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException('Null JSON in User constructor');
    }
    return User(
      json['email'] as String,
      json['password'] as String,
    );
  }

  int id;
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}