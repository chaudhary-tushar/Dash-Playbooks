import 'dart:math';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart'
    show AuthResult, UserRepository;

class AnonymousLoginUsecase {
  const AnonymousLoginUsecase(this.repository);
  final UserRepository repository;

  Future<AuthResult> call() async {
    try {
      // Generate unique session ID for tracking purposes
      final sessionId = _generateSessionId();

      // Call repository method for anonymous sign in
      final result = await repository.anonymousSignIn();

      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Anonymous login failed: $e',
      );
    }
  }

  /// Generates a unique session ID for tracking anonymous users
  String _generateSessionId() {
    // Create a unique ID using timestamp and random component
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random().nextInt(1000000).toString().padLeft(6, '0');
    return 'anon_${timestamp}_$random';
  }
}
