import '../repositories/user_repository.dart' show UserRepository;

class LogoutUsecase {
  final UserRepository repository;

  const LogoutUsecase(this.repository);

  Future<void> call() async {
    try {
      await repository.signOut();
    } catch (e) {
      // Ignore logout errors or log
    }
  }
}
