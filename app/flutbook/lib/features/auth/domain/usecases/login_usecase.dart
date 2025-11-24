import '../repositories/user_repository.dart' show UserRepository, AuthResult;

class LoginUsecase {
  final UserRepository repository;

  const LoginUsecase(this.repository);

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
