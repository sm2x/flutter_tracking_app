class User {
  String email;
  String password;
  String token;
  User({this.email, this.password, this.token});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json['email'], token: json['token']);
  }
}
