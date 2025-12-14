import 'package:flutbook/features/auth/domain/repositories/user_repository.dart' show AuthResult, UserRepository;

class LoginUsecase {

  const LoginUsecase(this.repository);
  final UserRepository repository;

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    try {
      return await repository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Login failed: $e',
      );
    }
  }
}
