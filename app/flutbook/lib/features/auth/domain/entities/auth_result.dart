import 'package:flutbook/features/auth/domain/entities/user_profile.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    this.userId,
    this.errorMessage,
    this.user,
  });
  final bool success;
  final String? userId;
  final String? errorMessage;
  final UserProfile? user;
}
