import '../entities/user_profile.dart';
import '../repositories/user_repository.dart' show UserRepository;

class GetCurrentUserUsecase {
  final UserRepository repository;

  const GetCurrentUserUsecase(this.repository);

  Future<UserProfile?> call() async {
    try {
      return await repository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}
