import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import './services/payment_service.dart';
import './services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web-specific initialization
  if (kIsWeb) {
    // Wait for a moment to ensure plugins are properly initialized
    await Future.delayed(const Duration(milliseconds: 500));
  }

  try {
    // Initialize Supabase
    await SupabaseService.initialize();

    // Initialize Stripe (only if keys are available)
    try {
      await PaymentService.initialize();
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: "Joyce's.ink",
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
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