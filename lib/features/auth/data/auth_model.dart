import '../../../shared/models/user_model.dart';

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;
  AuthResponse({required this.accessToken, this.refreshToken, required this.user});

  /// The login endpoint returns `{ accessToken, refreshToken, user }`.
  /// Some env may put the user under `profile` — `UserModel.fromJson`
  /// already handles either shape.
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken']?.toString() ?? '',
        refreshToken: json['refreshToken']?.toString(),
        user: UserModel.fromJson(
          (json['user'] ?? json['profile'] ?? <String, dynamic>{}) as Map<String, dynamic>,
        ),
      );
}
