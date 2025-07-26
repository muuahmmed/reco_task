import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Compare this snippet from lib/Register/services/firebase_service.dart:
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in the user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Return the signed-in user
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      switch (e.code) {
        case 'user-not-found':
          print('Error: No user found for that email.');
          break;
        case 'wrong-password':
          print('Error: The email address or the password is not valid.');
          break;
        case 'invalid-email':
          print('Error: The email address or the password is not valid.');
          break;
        case 'user-disabled':
          print('Error: The user account has been disabled.');
          break;
        default:
          print('Error signing in with email and password: ${e.message}');
      }
      return null;
    } catch (e) {
      // Handle any other errors
      print('Unexpected error signing in: $e');
      return null;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
