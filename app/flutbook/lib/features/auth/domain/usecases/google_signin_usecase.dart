import 'package:flutbook/features/auth/domain/repositories/user_repository.dart' show AuthResult, UserRepository;

class GoogleSigninUsecase {

  const GoogleSigninUsecase(this.repository);
  final UserRepository repository;

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
