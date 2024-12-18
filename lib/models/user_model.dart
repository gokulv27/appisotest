class UserModel {
  final int id;
  final String username;
  final bool newLogin;
  final String accessToken;
  final String refreshToken;

  UserModel({
    required this.id,
    required this.username,
    required this.newLogin,
    required this.accessToken,
    required this.refreshToken,
  });

  // Factory method to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] as int,
      username: json['username'] as String,
      newLogin: json['new_login'] as bool,
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }
}
