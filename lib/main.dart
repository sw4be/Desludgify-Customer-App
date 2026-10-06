import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth_store.dart';

// Auth / Onboarding
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/account_created_screen.dart';

// Main App Screens
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/live_tracking_screen.dart';
import 'screens/upload_images_screen.dart';
import 'screens/schedule_service_screen.dart';
import 'screens/pending_requests_screen.dart';
import 'screens/ongoing_requests_screen.dart';
import 'screens/scheduled_requests_screen.dart';
import 'screens/request_history_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/call_screen.dart';
import 'screens/notification_preferences_screen.dart';
import 'screens/security_screen.dart';
import 'screens/theme_controller.dart';
import 'screens/privacy_screen.dart';
import 'screens/verification_result._screen.dart';
import 'screens/verification_notification_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/password_sms_code_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.load();
  runApp(const DeslugifyApp());
}

class DeslugifyApp extends StatelessWidget {
  const DeslugifyApp({super.key});

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAF3),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF003D1A),
      brightness: Brightness.light,
      primary: const Color(0xFF003D1A),
      secondary: const Color(0xFF006D38),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF2F5EE),
      hintStyle: TextStyle(color: Color(0xFF707970)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE6E9E2),
      selectedColor: const Color(0xFF003D1A),
      labelStyle: const TextStyle(color: Color(0xFF191D19)),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF006D38),
      unselectedItemColor: Color(0xFF707970),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF003D1A),
      elevation: 0,
      centerTitle: true,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF08090A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE8EAED),
      brightness: Brightness.dark,
      primary: const Color(0xFFE8EAED),
      onPrimary: const Color(0xFF08090A),
      secondary: const Color(0xFFB8C0CC),
      surface: const Color(0xFF17181C),
      surfaceContainer: const Color(0xFF202126),
      onSurface: const Color(0xFFF5F6F7),
      onSurfaceVariant: const Color(0xFFB0B4BC),
      outline: const Color(0xFF3A3D44),
    ),
    textTheme: Typography.whiteCupertino,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF08090A),
      foregroundColor: Color(0xFFF5F6F7),
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: const Color(0xFF17181C),
    dividerTheme: const DividerThemeData(color: Color(0xFF2B2D33)),
    iconTheme: const IconThemeData(color: Color(0xFFE8EAED)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF202126),
      hintStyle: TextStyle(color: Color(0xFF9EA3AD)),
      labelStyle: TextStyle(color: Color(0xFFB0B4BC)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF3A3D44)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE8EAED)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF202126),
      selectedColor: const Color(0xFFE8EAED),
      labelStyle: const TextStyle(color: Color(0xFFE8EAED)),
      secondaryLabelStyle: const TextStyle(color: Color(0xFF08090A)),
      side: BorderSide(color: Color(0xFF3A3D44)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF08090A),
      selectedItemColor: Color(0xFFF5F6F7),
      unselectedItemColor: Color(0xFF9EA3AD),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8EAED),
        foregroundColor: const Color(0xFF08090A),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE8EAED),
      foregroundColor: Color(0xFF08090A),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF17181C),
      surfaceTintColor: Colors.transparent,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        // Update status bar icons for light/dark
        final isDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark);

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );

        return MaterialApp(
          title: 'Deslugify',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const SessionGate(),
          routes: <String, WidgetBuilder>{
            // Auth
            '/landing': (context) => const DeslugifyHomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const SignUpScreen(),
            '/otp': (context) => const VerifyIdentityScreen(),
            '/account-created': (context) => const AccountCreatedScreen(),

            // Main
            '/home': (context) => const DashboardScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/messages': (context) => const MessagesScreen(),
            '/live-call': (context) => const LiveCallScreen(),
            '/live-tracking': (context) => const LiveTrackingScreen(),
            '/upload-images': (context) => const UploadImagesScreen(),
            '/schedule-service': (context) => const ScheduleServiceScreen(),
            '/pending-requests': (context) => const PendingRequestsScreen(),
            '/ongoing-requests': (context) => const OngoingRequestsScreen(),
            '/scheduled-requests': (context) => const ScheduledRequestsScreen(),
            '/request-history': (context) => const RequestHistoryScreen(),
            '/feedback': (context) => const ServiceFeedbackScreen(),
            '/alerts': (context) => const AlertsScreen(),
            '/verification-result': (context) =>
                const VerificationResultScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/password-sms-code': (context) {
              final phone =
                  ModalRoute.of(context)?.settings.arguments as String?;
              return PasswordSmsCodeScreen(phoneNumber: phone);
            },
            '/verification-notification': (context) =>
                const VerificationNotificationScreen(),
            '/notification-preferences': (context) =>
                const NotificationPreferencesScreen(),
            '/security': (context) => const SecurityScreen(),
            '/privacy': (context) => const PrivacyScreen(),
          },
        );
      },
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<AppUser?> _session = AuthStore.currentUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Deslugify',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
        return snapshot.data == null
            ? const DeslugifyHomeScreen()
            : const DashboardScreen();
      },
    );
  }
}
