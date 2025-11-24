import '../repositories/user_repository.dart' show UserRepository, AuthResult;

class GoogleSigninUsecase {
  final UserRepository repository;

  const GoogleSigninUsecase(this.repository);

  Future<AuthResult> call() async {
    try {
      return await repository.signInWithGoogle();
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Google sign in failed: $e',
      );
    }
  }
}
