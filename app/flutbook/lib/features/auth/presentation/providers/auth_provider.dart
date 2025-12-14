import 'package:flutbook/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:flutbook/features/auth/data/repositories/user_repository_impl.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:flutbook/features/auth/domain/repositories/user_repository.dart';
import 'package:flutbook/features/auth/domain/usecases/anonymous_login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutbook/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutbook/features/library/data/datasources/remote/firebase_library_sync.dart';
import 'package:flutbook/features/player/data/datasources/remote/firebase_playback_sync.dart';
import 'package:flutbook/features/settings/data/datasources/preferences_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>(
  (ref) => FirebaseAuthDatasource(),
);

final libraryRemoteDatasourceProvider = Provider<LibraryRemoteDatasource>(
  (ref) => LibraryRemoteDatasource(),
);

final playbackRemoteDatasourceProvider = Provider<PlaybackRemoteDatasource>(
  (ref) => PlaybackRemoteDatasource(),
);

final preferencesDatasourceProvider = Provider<PreferencesDatasource>(
  (ref) => PreferencesDatasource(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    authDatasource: ref.watch(firebaseAuthDatasourceProvider),
    // Provide other deps using available providers
    syncDatasource: ref.watch(libraryRemoteDatasourceProvider),
    playbackRemoteDatasource: ref.watch(playbackRemoteDatasourceProvider),
    preferencesDatasource: ref.watch(preferencesDatasourceProvider),
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

extension on AsyncValue<UserProfile?> {
  Null get valueOrNull => null;
}
