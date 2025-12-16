import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart' show UserRepository;

class LoginUsecase {
  const LoginUsecase(this.repository);
  final UserRepository repository;

  /// RFC 5322 compliant email validation regex
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&"*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+$',
  );

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    // Validate email
    final emailValidation = _validateEmail(email);
    if (emailValidation != null) {
      return emailValidation;
    }

    // Validate password
    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      return passwordValidation;
    }

    try {
      return await repository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Login failed: $e',
      );
    }
  }

  /// Validates email format according to RFC 5322
  AuthResult? _validateEmail(String email) {
    if (email.isEmpty) {
      return const AuthResult(
        success: false,
        errorMessage: 'Email cannot be empty',
      );
    }

    if (!_emailRegex.hasMatch(email)) {
      return const AuthResult(
        success: false,
        errorMessage: 'Invalid email format',
      );
    }

    return null; // Validation passed
  }

  /// Validates password requirements
  AuthResult? _validatePassword(String password) {
    if (password.isEmpty) {
      return const AuthResult(
        success: false,
        errorMessage: 'Password cannot be empty',
      );
    }

    if (password.length < 6) {
      return const AuthResult(
        success: false,
        errorMessage: 'Password must be at least 6 characters',
      );
    }

    return null; // Validation passed
  }
}
