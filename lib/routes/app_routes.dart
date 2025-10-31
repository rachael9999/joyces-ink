import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../presentation/account_settings_screen/account_settings_screen.dart';
import '../presentation/export_data_screen/export_data_screen.dart';
import '../presentation/help_support_screen/help_support_screen.dart';
import '../presentation/journal_entry_creation/journal_entry_creation.dart';
import '../presentation/journal_home_screen/journal_home_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/login_screen/forgot_password_screen.dart';
import '../presentation/login_screen/reset_password_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/privacy_security_screen/privacy_security_screen.dart';
import '../presentation/register_screen/register_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/story_detail_screen/story_detail_screen.dart';
import '../presentation/story_generation_screen/story_generation_screen.dart';
import '../presentation/story_share_screen/story_share_screen.dart';
import '../presentation/subscription_screen/subscription_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/writing_preferences_screen/writing_preferences_screen.dart';

class AppRoutes {
      static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String initialRoute = '/initialRoute';

  static const String splashScreen = '/splash_screen';

  static const String journalHomeScreen = '/journal_home_screen';

  static const String onboardingFlow = '/onboarding_flow';

  static const String loginScreen = '/login_screen';
  static const String forgotPasswordScreen = '/forgot_password_screen';

  static const String registerScreen = '/register_screen';
      static const String resetPasswordScreen = '/reset_password_screen';

  static const String journalEntryCreation = '/journal_entry_creation';

  static const String storyGenerationScreen = '/story_generation_screen';


  static const String storyLibraryScreen = '/story_library_screen';

  static const String storyDetailScreen = '/story_detail_screen';
  static const String storyShareScreen = '/story_share_screen';

  static const String userProfileScreen = '/user_profile_screen';

  static const String accountSettingsScreen = '/account_settings_screen';

  static const String writingPreferencesScreen = '/writing_preferences_screen';

  static const String privacySecurityScreen = '/privacy_security_screen';

  static const String helpSupportScreen = '/help_support_screen';

  static const String exportDataScreen = '/export_data_screen';

  static const String subscriptionScreen = '/subscription_screen';

  static Map<String, WidgetBuilder> get routes => {
        initialRoute: (context) => const SplashScreen(),
        splashScreen: (context) => const SplashScreen(),
        journalHomeScreen: (context) => const JournalHomeScreen(),
        onboardingFlow: (context) => const OnboardingFlow(),
        loginScreen: (context) => const LoginScreen(),
  forgotPasswordScreen: (context) => const ForgotPasswordScreen(),
      resetPasswordScreen: (context) => const ResetPasswordScreen(),
        registerScreen: (context) => const RegisterScreen(),
        journalEntryCreation: (context) => const JournalEntryCreation(),
        storyGenerationScreen: (context) => const StoryGenerationScreen(),
        storyDetailScreen: (context) => const StoryDetailScreen(),
  storyShareScreen: (context) => const StoryShareScreen(),
        userProfileScreen: (context) => const UserProfileScreen(),
        accountSettingsScreen: (context) => const AccountSettingsScreen(),
        writingPreferencesScreen: (context) => const WritingPreferencesScreen(),
        privacySecurityScreen: (context) => const PrivacySecurityScreen(),
        helpSupportScreen: (context) => const HelpSupportScreen(),
        exportDataScreen: (context) => const ExportDataScreen(),
        subscriptionScreen: (context) => const SubscriptionScreen(),
      };
}
