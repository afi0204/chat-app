// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true)); // Use merge to avoid overwriting data
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // re-throw the exception to be caught by the UI
      throw e;
    }
  }

  // THIS METHOD IS NOW FULLY ASYNC AWAIT
  Future<UserCredential> signUpWithEmailPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(displayName);

      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': displayName,
        'photoURL': ''
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // re-throw the exception to be caught by the UI
      throw e;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
