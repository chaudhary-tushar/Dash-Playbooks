import 'package:flutbook/features/auth/domain/repositories/user_repository.dart'
    show AuthResult, UserRepository;

class AnonymousLoginUsecase {
  const AnonymousLoginUsecase(this.repository);
  final UserRepository repository;

  Future<AuthResult> call() async {
    try {
      return await repository.anonymousSignIn();
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Anonymous login failed: $e',
      );
    }
  }
}
