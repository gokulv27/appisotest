class UserModel {
  final int? id; // id can be nullable if user_id is not always present
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
      id: json['user_id'] != null ? json['user_id'] as int : 0, // Provide a default value of 0
      username: json['username'] ?? '', // Use an empty string as a fallback
      newLogin: json['new_login'] ?? false, // Default to false
      accessToken: json['access'] ?? '', // Empty string fallback
      refreshToken: json['refresh'] ?? '', // Empty string fallback
    );
  }
}
