import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rumaan/firestore_service.dart';
import 'dart:developer' as dev;

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  AppUser? _appUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _appUser != null;
  bool get isAdmin => _appUser?.role == UserRole.admin;
  bool get isReceptionist => _appUser?.role == UserRole.receptionist;
  bool get isCustomer => _appUser?.role == UserRole.customer;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        _appUser = await _firestoreService.getUser(user.uid);
        if (_appUser == null) {
          _appUser = AppUser(
            uid: user.uid,
            email: user.email,
            phoneNumber: user.phoneNumber,
            role: UserRole.customer,
          );
          await _firestoreService.createUser(_appUser!.uid, _appUser!.toFirestore());
        }
      } else {
        if (_appUser != null && 
            !(_appUser!.uid == 'hardcoded_admin_id_123' || 
              _appUser!.uid == 'hardcoded_receptionist_id_456')) {
          _appUser = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      dev.log('DEBUG: AuthProvider - Auth state changed. Current user UID: ${_appUser?.uid}, Role: ${_appUser?.role}');
    });
  }

  Future<void> signInWithPhoneNumber(
    String phoneNumber, {
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      UserCredential? userCredential = await _authService.signInWithPhoneCredential(credential);
      if (userCredential != null) {
        await refreshUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      dev.log('Error signing in with phone credential: $e');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      UserCredential? userCredential = await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential != null) {
        await refreshUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      dev.log('Error signing in with email/password: $e');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void setHardcodedAdminUser() async {
    _isLoading = true;
    notifyListeners();
    
    _currentUser = null;
    _appUser = AppUser(
      uid: 'hardcoded_admin_id_123',
      email: 'admin@rumaanhotel.com',
      role: UserRole.admin,
    );
    
    await _firestoreService.createUser(_appUser!.uid, _appUser!.toFirestore());
    _isLoading = false;
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: 'Logged in as Admin',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    dev.log('DEBUG: AuthProvider - Hardcoded Admin set. UID: ${_appUser?.uid}, Role: ${_appUser?.role}');
  }

  void setHardcodedReceptionistUser() async {
    _isLoading = true;
    notifyListeners();
    
    _currentUser = null;
    _appUser = AppUser(
      uid: 'hardcoded_receptionist_id_456',
      email: 'receptionist@rumaanhotel.com',
      role: UserRole.receptionist,
    );
    
    await _firestoreService.createUser(_appUser!.uid, _appUser!.toFirestore());
    _isLoading = false;
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: 'Logged in as Receptionist',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    dev.log('DEBUG: AuthProvider - Hardcoded Receptionist set. UID: ${_appUser?.uid}, Role: ${_appUser?.role}');
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.signOut();
    _currentUser = null;
    _appUser = null;
    _isLoading = false;
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: 'Logged out successfully',
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  Future<void> refreshUser() async {
    if (_currentUser != null) {
      _appUser = await _firestoreService.getUser(_currentUser!.uid);
      notifyListeners();
    }
  }

  // Navigation helper methods
  bool shouldRedirectFromAuth() {
    return isAuthenticated;
  }

  String getRedirectRoute() {
    if (!isAuthenticated) return '/';
    
    if (isAdmin || isReceptionist) {
      return '/admin-dashboard';
    } else {
      return '/customer-dashboard';
    }
  }
}