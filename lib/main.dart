import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/analytics_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/admin_auth_screen.dart';
import 'screens/customer_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Rumaan Hotel Coupons',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.blue[700],
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue[700]!,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                color: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
            ),
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/customer-dashboard',
      builder: (context, state) => const CustomerDashboardScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin-auth',
      builder: (context, state) => const AdminAuthScreen(),
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = authProvider.isAuthenticated;
    final currentLocation = state.matchedLocation;
    final loggingIn = currentLocation == '/' || currentLocation == '/admin-auth';

    // If not logged in and trying to access protected routes, redirect to auth
    if (!loggedIn && !loggingIn) {
      return '/';
    }

    // If logged in and trying to access auth screens, redirect to appropriate dashboard
    if (loggedIn && loggingIn) {
      return authProvider.getRedirectRoute();
    }

    // If logged in but trying to access wrong dashboard, redirect to correct one
    if (loggedIn) {
      if ((authProvider.isAdmin || authProvider.isReceptionist) && 
          currentLocation == '/customer-dashboard') {
        return '/admin-dashboard';
      }
      if (authProvider.isCustomer && currentLocation == '/admin-dashboard') {
        return '/customer-dashboard';
      }
    }

    return null;
  },
);