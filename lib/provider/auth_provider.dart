import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart'; // Using logger for better debugging

enum UserRole { unknown, customer, admin, receptionist }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  User? _currentUser;
  UserRole _userRole = UserRole.unknown;
  String? _verificationId;
  int? _resendToken;
  bool _isLoading = true; // Initial loading state for auth status

  User? get currentUser => _currentUser;
  UserRole get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        await _fetchUserRole(user.uid);
      } else {
        _userRole = UserRole.unknown;
        _isLoading = false; // Set loading to false even if no user
        notifyListeners();
      }
      _logger.d('Auth State Changed: User: ${user?.uid}, Role: $_userRole, IsLoading: $_isLoading');
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final roleString = data?['role'] as String?;
        if (roleString != null) {
          _userRole = UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == roleString,
            orElse: () => UserRole.customer, // Default to customer if role not found
          );
        } else {
          _userRole = UserRole.customer; // Default if role field is missing
        }
      } else {
        // If user document doesn't exist, create it as a customer
        _userRole = UserRole.customer;
        await _firestore.collection('users').doc(uid).set({
          'phoneNumber': _currentUser?.phoneNumber,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      _logger.d('Fetched user role for $uid: $_userRole');
    } catch (e) {
      _logger.e('Error fetching user role: $e');
      _userRole = UserRole.unknown; // Fallback
    } finally {
      _isLoading = false; // Always set loading to false after role check
      notifyListeners();
    }
  }

  // Phone Authentication
  Future<String?> sendOtp(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    _logger.d('Sending OTP to $phoneNumber');
    String? errorMessage;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _logger.d('Verification completed automatically.');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _logger.e('Verification failed: ${e.code} - ${e.message}');
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'The provided phone number is not valid.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (e.code == 'missing-verification-id') {
            errorMessage = 'Missing verification ID. Please try again.';
          } else if (e.code == 'session-expired') {
            errorMessage = 'Session expired. Please resend the OTP.';
          } else if (e.code == 'network-request-failed') {
            errorMessage = 'Network error. Please check your internet connection.';
          } else if (e.code == 'app-not-authorized') {
            errorMessage = 'App not authorized for phone authentication. Check Firebase settings.';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again later or enable billing.';
          } else {
            errorMessage = 'Verification failed: ${e.message}';
          }
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _logger.d('Code sent. Verification ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.d('Code auto-retrieval timeout.');
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken, // Pass resend token for explicit resend
      );
    } catch (e) {
      _logger.e('Error in sendOtp: $e');
      errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
    return errorMessage;
  }

  Future<String?> verifyOtpAndSignIn(String smsCode) async {
    _isLoading = true;
    notifyListeners();
    _logger.d('Verifying OTP: $smsCode');
    String? errorMessage;
    try {
      if (_verificationId == null) {
        errorMessage = 'Verification ID is missing. Please resend OTP.';
        _logger.w('Verification ID is null when trying to verify OTP.');
        return errorMessage;
      }
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      _logger.i('OTP verification successful. User signed in.');
    } on FirebaseAuthException catch (e) {
      _logger.e('OTP verification failed: ${e.code} - ${e.message}');
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid verification code. Please try again.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'The verification code has expired. Please resend.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Failed to verify OTP: ${e.message}';
      }
    } catch (e) {
      _logger.e('Error in verifyOtpAndSignIn: $e');
      errorMessage = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return errorMessage;
  }

  // Admin/Receptionist Login (Email/Password for simplicity, or custom token)
  Future<bool> loginAdmin(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    _logger.d('Attempting admin login for: $email');
    try {
      // For demo purposes, use hardcoded admin credentials
      // In a real app, you'd use Firebase Authentication (Email/Password or custom)
      // and then verify their role from Firestore.
      if (email == 'admin@rumanhotel' && password == 'RumanAdmin2024!') {
        // Simulate successful login and set role
        // For a real app, you'd sign in with email/password and then fetch role
        _currentUser = _auth.currentUser ?? (await _auth.signInAnonymously()).user; // Use anonymous if no user
        _userRole = UserRole.admin;
        _logger.i('Admin demo login successful.');
        notifyListeners();
        return true;
      } else if (email == 'receptionist@rumanhotel' && password == 'RumanReceptionist2024!') {
        _currentUser = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
        _userRole = UserRole.receptionist;
        _logger.i('Receptionist demo login successful.');
        notifyListeners();
        return true;
      } else {
        _logger.w('Invalid admin/receptionist credentials for $email');
        return false;
      }
    } catch (e) {
      _logger.e('Error during admin login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _logger.i('Signing out user.');
    await _auth.signOut();
    _currentUser = null;
    _userRole = UserRole.unknown;
    notifyListeners();
  }
}
