/// Base failure classes for centralized error handling across data sources and usecases.
/// Defines common failure types like CacheFailure, ServerFailure for consistent error management.
library;

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class ServerFailure extends Failure {
  const ServerFailure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class PermissionFailure extends Failure {
  const PermissionFailure();
}
