import 'package:flutter/material.dart';

// Auth
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/signin_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/complete_profile_screen.dart';

// Map
import '../features/map/screens/home_screen.dart';

// Alerts
import '../features/alerts/screens/alerts_screen.dart';
import '../features/alerts/screens/alert_detail_screen.dart';

// Report
import '../features/report/screens/report_screen.dart';
import '../features/report/screens/report_success_screen.dart';

// Profile
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/notification_settings_screen.dart';
import '../features/profile/screens/safe_zones_screen.dart';
import '../features/profile/screens/language_screen.dart';

// Verified
import '../features/verified/screens/verified_reporter_screen.dart';

class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';

  // Core
  static const String home = '/home';
  static const String alerts = '/alerts';
  static const String alertDetail = '/alert-detail';
  static const String report = '/report';
  static const String reportSuccess = '/report-success';

  // Profile
  static const String profile = '/profile';
  static const String notificationSettings = '/notification-settings';
  static const String safeZones = '/safe-zones';
  static const String language = '/language';

  // Verified
  static const String verifiedReporter = '/verified-reporter';

  // Static routes (no arguments needed)
  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    signIn: (_) => const SignInScreen(),
    signUp: (_) => const SignUpScreen(),
    completeProfile: (_) => const CompleteProfileScreen(),
    home: (_) => const HomeScreen(),
    alerts: (_) => const AlertsScreen(),
    alertDetail: (_) => const AlertDetailScreen(),
    report: (_) => const ReportScreen(),
    reportSuccess: (_) => const ReportSuccessScreen(),
    profile: (_) => const ProfileScreen(),
    notificationSettings: (_) => const NotificationSettingsScreen(),
    safeZones: (_) => const SafeZonesScreen(),
    language: (_) => const LanguageScreen(),
    verifiedReporter: (_) => const VerifiedReporterScreen(),
  };

  // Dynamic route — OTP screen needs phoneNumber + verificationId arguments
  static Route<dynamic> generateOtpRoute({
    required String phoneNumber,
    required String verificationId,
  }) {
    return MaterialPageRoute(
      builder: (_) => OtpScreen(
        phoneNumber: phoneNumber,
        verificationId: verificationId,
      ),
    );
  }
}