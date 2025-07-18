import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rumaan/firestore_service.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';


class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser; // This will be null for the hardcoded admin
  AppUser? _appUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _appUser != null; // Check if any user (Firebase or hardcoded) is set
  bool get isAdmin => _appUser?.role == UserRole.admin;
  bool get isReceptionist => _appUser?.role == UserRole.receptionist;
  bool get isCustomer => _appUser?.role == UserRole.customer;

  AuthProvider() {
    // Listen to Firebase auth state changes for real users
    _authService.authStateChanges.listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        _appUser = await _firestoreService.getUser(user.uid);
      } else {
        // If Firebase user logs out, clear our app user state
        _appUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // This method is for Firebase Phone OTP authentication
  Future<void> signInWithPhoneNumber(
    String phoneNumber, {
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    _isLoading = false;
    notifyListeners();
  }

  // This method is for Firebase Phone OTP credential sign-in
  Future<bool> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? userCredential = await _authService.signInWithPhoneCredential(credential);
    if (userCredential != null) {
      await refreshUser(); // Refresh user data after successful Firebase login
    }
    _isLoading = false;
    notifyListeners();
    return userCredential != null;
  }

  // This method is for Firebase Email/Password authentication (not used by hardcoded admin)
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? userCredential = await _authService.signInWithEmailAndPassword(email, password);
    if (userCredential != null) {
      await refreshUser(); // Refresh user data after successful Firebase login
    }
    _isLoading = false;
    notifyListeners();
    return userCredential != null;
  }

  // NEW: Method to set a hardcoded admin user (NOT SECURE FOR PRODUCTION)
  void setHardcodedAdminUser() {
    _isLoading = true;
    notifyListeners();
    _currentUser = null; // No Firebase User for this
    _appUser = AppUser(
      uid: 'hardcoded_admin_id_123', // A unique ID for this hardcoded user
      email: 'admin@rumanhotel.com',
      role: UserRole.admin,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    // Attempt Firebase sign out (will do nothing if not a Firebase user)
    await _authService.signOut();
    // Always clear our internal state regardless of Firebase status
    _currentUser = null;
    _appUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    // Only attempt to refresh if there's a real Firebase user
    if (_currentUser != null) {
      _appUser = await _firestoreService.getUser(_currentUser!.uid);
      notifyListeners();
    }
    // If _appUser was set by setHardcodedAdminUser, this method does not overwrite it.
  }
}
