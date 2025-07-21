import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rumaan/firestore_service.dart';
import 'dart:developer' as dev; // Import for dev.log

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
        if (_appUser == null) {
          _appUser = AppUser(
            uid: user.uid,
            email: user.email,
            phoneNumber: user.phoneNumber,
            role: UserRole.customer, // Default role for new sign-ups
          );
          await _firestoreService.createUser(_appUser!.uid, _appUser!.toFirestore());
        }
      } else {
        // If Firebase user logs out, clear our app user state
        // Only clear if the current _appUser is NOT a hardcoded user.
        // This prevents hardcoded users from being immediately logged out by authStateChanges.
        if (_appUser != null && !(_appUser!.uid == 'hardcoded_admin_id_123' || _appUser!.uid == 'hardcoded_receptionist_id_456')) {
          _appUser = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      dev.log('DEBUG: AuthProvider - Auth state changed. Current user UID: ${_appUser?.uid}, Role: ${_appUser?.role}');
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
  void setHardcodedAdminUser() async { // Made async
    _isLoading = true;
    notifyListeners();
    _currentUser = null; // No Firebase User for this
    _appUser = AppUser(
      uid: 'hardcoded_admin_id_123', // A unique ID for this hardcoded user
      email: 'admin@rumaanhotel.com',
      role: UserRole.admin,
    );
    // Ensure the hardcoded user document exists in Firestore
    await _firestoreService.createUser(_appUser!.uid, _appUser!.toFirestore());
    _isLoading = false;
    notifyListeners();
    Fluttertoast.showToast(msg: 'Logged in as hardcoded admin.');
    dev.log('DEBUG: AuthProvider - Hardcoded Admin set. UID: ${_appUser?.uid}, Role: ${_appUser?.role}');
  }

  // NEW: Method to set a hardcoded receptionist user (NOT SECURE FOR PRODUCTION)
  void setHardcodedReceptionistUser() async { // Made async
    _isLoading = true;
    notifyListeners();
    _currentUser = null; // No Firebase User for this
    _appUser = AppUser(
      uid: 'hardcoded_receptionist_id_456', // A unique ID for this hardcoded user
      email: 'receptionist@rumaanhotel.com',
      role: UserRole.receptionist,
    );
    // Ensure the hardcoded user document exists in Firestore
    await _firestoreService.createUser(_appUser!.uid, _appUser!.toFirestore());
    _isLoading = false;
    notifyListeners();
    Fluttertoast.showToast(msg: 'Logged in as hardcoded receptionist.');
    dev.log('DEBUG: AuthProvider - Hardcoded Receptionist set. UID: ${_appUser?.uid}, Role: ${_appUser?.role}');
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
