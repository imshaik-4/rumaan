import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rumaan/admin/admin_dashboard_screen.dart';
import 'package:rumaan/admin/admin_login_screen.dart';
import 'package:rumaan/admin/scanner_screen.dart';
import 'package:rumaan/firebase_options.dart'; // Ensure this file exists and is correct
import 'package:rumaan/app_theme.dart';

// Providers
import 'package:rumaan/provider/auth_provider.dart';
import 'package:rumaan/provider/coupon_provider.dart';
import 'package:rumaan/provider/analytics_provider.dart';

// Screens
import 'package:rumaan/screens/splash_screen.dart';
import 'package:rumaan/screens/home_screen.dart';
import 'package:rumaan/screens/customer_login_screen.dart';
import 'package:rumaan/screens/customer_dashboard_screen.dart';
import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dev.log('Main: WidgetsFlutterBinding initialized.');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    dev.log('Main: Firebase initialized successfully.');
  } catch (e) {
    dev.log('Main: Firebase initialization failed: $e');
    // You might want to show an error screen here in a real app
  }

  runApp(const MyApp());
  dev.log('Main: MyApp started.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('MyApp: Building MaterialApp.');
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard phone dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CouponProvider()),
            ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
          ],
          child: MaterialApp(
            title: 'Ruman Hotel Coupon App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              '/customer_login': (context) => const CustomerLoginScreen(),
              '/customer_dashboard': (context) => const CustomerDashboardScreen(),
              '/admin_login': (context) => const AdminLoginScreen(),
              '/admin_dashboard': (context) => const AdminDashboardScreen(),
              '/admin/scanner': (context) => const ScannerScreen(),
            },
          ),
        );
      },
    );
  }
}
