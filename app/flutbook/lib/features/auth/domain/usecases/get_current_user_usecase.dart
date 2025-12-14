import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart'
    show UserRepository;

class GetCurrentUserUsecase {
  const GetCurrentUserUsecase(this.repository);
  final UserRepository repository;

  Future<UserProfile?> call() async {
    try {
      return await repository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}
