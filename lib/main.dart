import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import './services/payment_service.dart';
import './services/auth_service.dart';
import './services/supabase_service.dart';
import './services/env_service.dart';
import './services/local_db.dart';
import './services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web-specific initialization
  if (kIsWeb) {
    // Wait for a moment to ensure plugins are properly initialized
    await Future.delayed(const Duration(milliseconds: 500));
  }

  try {
    // Initialize backend(s)
    if (EnvService.useSqlite && !kIsWeb) {
      // Local-only mode: init SQLite, skip Supabase
      await LocalDb.instance.init();
    } else {
      // Supabase cloud mode
      await SupabaseService.initialize();
    }

    // Load persisted app settings (privacy mode, auto-backup, last backup)
    try {
      await SettingsService.instance.load();
    } catch (_) {}

    // Initialize Stripe (only if in Supabase mode and keys are available)
    try {
      if (!EnvService.useSqlite) {
        await PaymentService.initialize();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization failed: $e');
      }
      // Continue app launch even if Stripe fails to initialize
    }

    runApp(MyApp());
  } catch (e) {
    if (kDebugMode) {
      print('App initialization failed: $e');
    }
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Handle Supabase password recovery deep link event
    AuthService.instance.authStateChanges.listen((state) {
      final eventString = state.event.toString().toLowerCase();
      if (eventString.contains('passwordrecovery') || eventString.contains('recovery')) {
        // Navigate to reset password screen
        AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.resetPasswordScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: "Joyce's.ink",
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        navigatorKey: AppRoutes.navigatorKey,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initialRoute,
      );
    });
  }
}