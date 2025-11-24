import 'package:flutbook/features/auth/domain/repositories/user_repository.dart'
    show AuthResult, UserRepository;

class AnonymousLoginUsecase {
  final UserRepository repository;

  const AnonymousLoginUsecase(this.repository);

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
