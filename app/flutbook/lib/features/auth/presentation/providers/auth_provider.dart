import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/firebase_auth_datasource.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/anonymous_login_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/google_signin_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../entities/user_profile.dart';

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>(
  (ref) => FirebaseAuthDatasource(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    authDatasource: ref.watch(firebaseAuthDatasourceProvider),
    // Stub other deps for auth focus
    syncDatasource: throw UnimplementedError(),
    playbackRemoteDatasource: throw UnimplementedError(),
    preferencesDatasource: throw UnimplementedError(),
  ),
);

final anonymousLoginUsecaseProvider = Provider<AnonymousLoginUsecase>(
  (ref) => AnonymousLoginUsecase(ref.watch(userRepositoryProvider)),
);

final loginUsecaseProvider = Provider<LoginUsecase>(
  (ref) => LoginUsecase(ref.watch(userRepositoryProvider)),
);

final googleSigninUsecaseProvider = Provider<GoogleSigninUsecase>(
  (ref) => GoogleSigninUsecase(ref.watch(userRepositoryProvider)),
);

final logoutUsecaseProvider = Provider<LogoutUsecase>(
  (ref) => LogoutUsecase(ref.watch(userRepositoryProvider)),
);

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>(
  (ref) => GetCurrentUserUsecase(ref.watch(userRepositoryProvider)),
);

final authStateProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(userRepositoryProvider).authStateChanges(),
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authStateProvider).valueOrNull != null,
);
