import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  String? _verificationId;
  bool _otpSent = false;
  int _adminTapCount = 0;
  int _currentPage = 0;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Set default country code
    _phoneController.text = '+91 ';
    
    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationStatus();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  void _checkAuthenticationStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      _navigateToAppropriateScreen(authProvider);
    }
  }

  void _navigateToAppropriateScreen(AuthProvider authProvider) {
    if (authProvider.isAdmin || authProvider.isReceptionist) {
      context.go('/admin-dashboard');
    } else {
      context.go('/customer-dashboard');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green[600],
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    }
  }

  String _formatPhoneNumber(String input) {
    // Remove all non-digit characters except +
    String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with +91
    if (!cleaned.startsWith('+91')) {
      if (cleaned.startsWith('91')) {
        cleaned = '+$cleaned';
      } else if (cleaned.startsWith('+')) {
        cleaned = '+91${cleaned.substring(1)}';
      } else {
        cleaned = '+91$cleaned';
      }
    }
    
    return cleaned;
  }

  Future<void> _verifyPhoneNumber() async {
    if (_isLoading) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = _formatPhoneNumber(_phoneController.text.trim());
    
    // Validate phone number format
    if (phoneNumber.length < 13) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authProvider.signInWithPhoneNumber(
        phoneNumber,
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          if (!mounted) return;
          
          try {
            bool success = await authProvider.signInWithPhoneCredential(credential);
            if (success && mounted) {
              _showSuccess('Phone verification completed!');
              await Future.delayed(const Duration(milliseconds: 500));
              _navigateToAppropriateScreen(authProvider);
            }
          } catch (e) {
            if (mounted) {
              _showError('Authentication failed. Please try again.');
            }
          }
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showError('Phone verification failed: ${e.message ?? "Unknown error"}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _otpSent = true;
              _isLoading = false;
            });
            _showSuccess('OTP sent to your phone!');
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to send OTP. Please try again.');
      }
    }
  }

  Future<void> _signInWithOtp() async {
    if (_isLoading) return;
    
    if (_verificationId == null) {
      _showError('Please verify phone number first.');
      return;
    }
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showError('Please enter a valid 6-digit OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    fb_auth.PhoneAuthCredential credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text,
    );

    try {
      bool success = await authProvider.signInWithPhoneCredential(credential);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          _showSuccess('Welcome to Rumaan Hotel!');
          // Small delay to ensure UI updates
          await Future.delayed(const Duration(milliseconds: 500));
          _navigateToAppropriateScreen(authProvider);
        } else {
          _showError('Invalid OTP. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Invalid OTP. Please try again.');
      }
    }
  }

  void _handleAdminTap() {
    setState(() {
      _adminTapCount++;
      if (_adminTapCount >= 5) {
        _adminTapCount = 0;
        context.push('/admin-auth');
      }
    });
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _otpSent = false;
        _verificationId = null;
        _otpController.clear();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If user is authenticated, redirect immediately
        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToAppropriateScreen(authProvider);
          });
          return _buildLoadingScreen();
        }

        return PopScope(
          canPop: false,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[500]!,
                    Colors.blue[300]!,
                  ],
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(),
                        // Content
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                children: [
                                  _buildPhoneInputPage(),
                                  _buildOtpInputPage(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[700]!,
              Colors.blue[500]!,
              Colors.blue[300]!,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isKeyboardVisible ? 16.w : 24.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleAdminTap,
            child: Container(
              padding: EdgeInsets.all(isKeyboardVisible ? 12.w : 20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_hotel,
                size: isKeyboardVisible ? 32.sp : 48.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isKeyboardVisible ? 8.h : 16.h),
          GestureDetector(
            onTap: _handleAdminTap,
            child: Column(
              children: [
                Text(
                  'Rumaan Hotel',
                  style: TextStyle(
                    fontSize: isKeyboardVisible ? 24.sp : 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isKeyboardVisible)
                  Text(
                    'Coupon System',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputPage() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter your phone number to continue',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 40.h),

          // Phone Input
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontSize: 16.sp),
              onChanged: (value) {
                // Ensure +91 prefix is maintained
                if (!value.startsWith('+91')) {
                  _phoneController.text = '+91 ';
                  _phoneController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _phoneController.text.length),
                  );
                }
              },
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+91 9876543210',
                prefixIcon: Container(
                  margin: EdgeInsets.all(12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.phone,
                    color: Colors.blue[700],
                    size: 20.sp,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 16.w,
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Info Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'We\'ll send you a verification code via SMS',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40.h),

          // Send OTP Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyPhoneNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildOtpInputPage() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back Button
          Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Verification',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Text(
            'Enter OTP',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We sent a 6-digit code to ${_phoneController.text}',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 40.h),

          // OTP Input
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 8.w,
              ),
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                hintText: '000000',
                prefixIcon: Container(
                  margin: EdgeInsets.all(12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.vpn_key,
                    color: Colors.green[700],
                    size: 20.sp,
                  ),
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 16.w,
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Resend OTP
          Center(
            child: TextButton(
              onPressed: _goBack,
              child: Text(
                'Didn\'t receive code? Resend',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 40.h),

          // Verify Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Verify & Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}