// lib/features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutbook/features/auth/domain/entities/auth_result.dart';
import 'package:flutbook/features/auth/domain/entities/user_profile.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Flag to ensure GoogleSignIn is initialized before use (new requirement for v7.0.0+)
  bool _isGoogleSignInInitialized = false;

  /// Initializes the GoogleSignIn client. This MUST be called and awaited
  /// exactly once before calling any other GoogleSignIn methods (v7.0.0+ requirement).
  Future<void> initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) {
      return;
    }
    try {
      // The new mandatory initialization call
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
      print('GoogleSignIn initialized successfully.');
    } catch (e) {
      print('Error initializing GoogleSignIn: $e');
      // Depending on app logic, you might want to rethrow or handle gracefully.
      rethrow;
    }
  }

  /// Signs in with email and password
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.uid,
          email: user.email ?? email,
          displayName: user.displayName,
          authMethod: 'email_password',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.uid,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Authentication failed: No user returned',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _mapAuthError(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to sign in: $e',
      );
    }
  }

  /// Signs up with email and password
  Future<AuthResult> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.uid,
          email: user.email ?? email,
          displayName: user.displayName,
          authMethod: 'email_password',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.uid,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Account creation failed: No user returned',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _mapAuthError(e.code),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Failed to create account: $e',
      );
    }
  }

  /// Signs in with Google
  Future<AuthResult> signInWithGoogle() async {
    if (!_isGoogleSignInInitialized) {
      // For simplicity, attempt to initialize if not done.
      // In a real app, this is typically called in main() or a repository layer.
      await initializeGoogleSignIn();
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'Google sign in cancelled by user',
        );
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? googleUser.displayName,
          authMethod: 'google_oauth',
          syncEnabled: true,
        );

        return AuthResult(
          success: true,
          userId: user.uid,
          user: userProfile,
        );
      } else {
        return const AuthResult(
          success: false,
          errorMessage: 'Google authentication failed: No user returned',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _mapAuthError(e.code),
      );
    } on Exception catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Google sign in failed: $e',
      );
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  /// Gets the current authenticated user
  Future<UserProfile?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        authMethod: 'email_password', // Default assumption; in real impl would track auth method
        syncEnabled: true,
      );
    }
    return null;
  }

  /// Maps Firebase error codes to user-friendly messages
  String _mapAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Email is invalid.';
      case 'account-exists-with-different-credential':
        return 'An account with this email already exists with a different sign-in method.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
