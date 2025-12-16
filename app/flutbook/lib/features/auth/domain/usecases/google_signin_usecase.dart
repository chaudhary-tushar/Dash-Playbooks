import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart' show UserRepository;

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
