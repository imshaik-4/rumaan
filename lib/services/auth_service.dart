import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching user data: $e');
    }
    return null;
  }

  // Phone OTP Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential?> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'phoneNumber': userCredential.user!.phoneNumber,
        'role': UserRole.customer.toString().split('.').last,
        'redeemedCoupons': [],
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Phone sign-in failed');
      return null;
    }
  }

  // Email/Password Authentication (for Admin/Receptionist)
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Ensure user has a role in Firestore, default to unknown if not set
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'role': UserRole.unknown.toString().split('.').last, // Role will be updated by admin
        'redeemedCoupons': [],
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Email sign-in failed');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  signInWithEmailAndPassword(String email, String password) {}
}
