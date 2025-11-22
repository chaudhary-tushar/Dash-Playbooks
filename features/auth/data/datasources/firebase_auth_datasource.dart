// features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class FirebaseAuthDatasource {
  /// Stream of authentication state changes
  Stream<firebase_auth.User?> get authStateChanges;

  /// Gets the current authenticated user
  firebase_auth.User? get currentUser;

  /// Signs in with email and password
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs in with Google
  Future<firebase_auth.UserCredential> signInWithGoogle();

  /// Creates a new user account
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user
  Future<void> signOut();
}

class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasourceImpl({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await firebase_auth.GoogleAuthProvider().credential();

    // Obtain the auth details from the request
    final userCredential = await _firebaseAuth.signInWithCredential(googleUser);

    return userCredential;
  }

  @override
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}