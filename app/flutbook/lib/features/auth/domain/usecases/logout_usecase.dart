import 'package:flutbook/features/auth/domain/repositories/user_repository.dart' show UserRepository;

class LogoutUsecase {

  const LogoutUsecase(this.repository);
  final UserRepository repository;

  Future<void> call() async {
    try {
      await repository.signOut();
    } catch (e) {
      // Ignore logout errors or log
    }
  }
}
