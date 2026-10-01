import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/role_selector.dart';

class AuthService {
  AuthService({this.auth, this.firestore});

  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firebaseFirestore => firestore ?? FirebaseFirestore.instance;

  Future<String?> signIn(String email, String password, UserRole selectedRole) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      final document = await _firebaseFirestore.collection('users').doc(credential.user!.uid).get();
      final storedRole = document.data()?['role'] as String?;
      final expectedRole = selectedRole.name;
      if (storedRole != expectedRole) {
        await _firebaseAuth.signOut();
        return 'This account is not registered as $expectedRole';
      }
      return null;
    } on FirebaseAuthException catch (error) {
      return _authErrorMessage(error);
    } on FirebaseException catch (error) {
      if (error.code == 'unavailable') return 'No internet connection. Please try again.';
      return 'We could not complete the sign in. Please try again.';
    }
  }

  Future<String?> registerPatient(String name, String email, String password, String phone) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await _firebaseFirestore.collection('users').doc(credential.user!.uid).set({
        'role': UserRole.patient.name,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      });
      return null;
    } on FirebaseAuthException catch (error) {
      return _authErrorMessage(error);
    } on FirebaseException catch (error) {
      if (error.code == 'unavailable') return 'No internet connection. Please try again.';
      return 'We could not create your account. Please try again.';
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<UserRole?> getCurrentUserRole() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      final document = await _firebaseFirestore.collection('users').doc(user.uid).get();
      final role = document.data()?['role'] as String?;
      return UserRole.values.where((value) => value.name == role).firstOrNull;
    } on FirebaseException {
      return null;
    } on StateError {
      return null;
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-credential' || 'wrong-password' => 'The email or password is incorrect.',
      'user-not-found' => 'No account was found with that email.',
      'invalid-email' => 'Please enter a valid email address.',
      'network-request-failed' => 'No internet connection. Please try again.',
      'email-already-in-use' => 'An account already exists with that email.',
      'weak-password' => 'Please choose a stronger password.',
      _ => 'We could not complete the request. Please try again.',
    };
  }
}