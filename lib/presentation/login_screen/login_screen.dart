import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Prevent multiple simultaneous login attempts
    if (_isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Enhanced input validation with null safety
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          throw Exception('Please fill in all fields.');
        }

        // Pre-check if auth service is available
        if (!AuthService.instance.isSignedIn) {
          // This is expected for login, but we check initialization
        }

        final response = await AuthService.instance.signIn(
          email: email,
          password: password,
        );

        // Enhanced response validation with comprehensive null safety
        if (!mounted) return; // Widget disposed during async operation

        // Validate response components separately
        final user = response.user;
        final session = response.session;

        if (user == null) {
          throw Exception('Authentication failed - no user data received.');
        }

        if (session == null) {
          throw Exception('Authentication failed - no session data received.');
        }

        // Additional validation for critical user properties
        final userId = user.id;
        final userEmail = user.email;

        if (userId.isEmpty) {
          throw Exception('Authentication failed - invalid user identifier.');
        }

        if (userEmail == null || userEmail.isEmpty) {
          throw Exception('Authentication failed - invalid user email.');
        }

        // Success path - update loading state first
        setState(() => _isLoading = false);

        // Show success message with null-safe email display
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, $userEmail!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Small delay to let success message show before navigation
        await Future.delayed(Duration(milliseconds: 300));

        // Navigate to home screen if still mounted
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.journalHomeScreen);
        }
      } catch (error) {
        // Ensure loading state is reset on any error
        if (mounted) {
          setState(() => _isLoading = false);

          // Enhanced error message handling with null safety
          String errorMessage =
              'An unexpected error occurred. Please try again.';

          if (error is Exception) {
            final exceptionMessage = error.toString();
            if (exceptionMessage.isNotEmpty) {
              errorMessage = exceptionMessage.replaceFirst('Exception: ', '');
            }
          }

          // Show user-friendly error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, AppRoutes.registerScreen);
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPasswordScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
              AppTheme.lightTheme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 4.h),

                      // App Logo and Branding
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CustomImageWidget(
                          imageUrl:
                              'assets/images/_____2025-10-22_175115-1761185495284.png',
                          width: 16.w,
                          height: 16.w,
                          semanticLabel:
                              'Hand-drawn artistic illustration of a person with scribbled messy hair in black ink lines, creative journaling app icon',
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // App Name with Artistic Typography
                      Text(
                        "Joyce's.ink",
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2.0,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        'Where stories breathe life',
                        style: AppTheme.lightTheme.textTheme.bodyLarge
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                      ),

                      SizedBox(height: 6.h),

                      // Login Form Card
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: LoginFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          isLoading: _isLoading,
                          onTogglePasswordVisibility: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          onLogin: _handleLogin,
                          onForgotPassword: _navigateToForgotPassword,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Demo Credentials Section
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'info',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 4.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Demo Credentials',
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .primary,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Premium User: sarah.johnson@joycesink.com / password123',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                            Text(
                              'Free User: demo@joycesink.com / demo123',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Social Login Section
                      SocialLoginWidget(
                        onGoogleLogin: () async {
                          if (_isLoading) return;
                          setState(() => _isLoading = true);
                          try {
                            await AuthService.instance.signInWithGoogle();
                            // On web this may redirect; on success navigate if returned
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Google sign-in initiated')),
                            );
                            await Future.delayed(const Duration(milliseconds: 300));
                            if (mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.journalHomeScreen);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        onAppleLogin: () async {
                          if (_isLoading) return;
                          setState(() => _isLoading = true);
                          try {
                            await AuthService.instance.signInWithApple();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Apple sign-in initiated')),
                            );
                            await Future.delayed(const Duration(milliseconds: 300));
                            if (mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.journalHomeScreen);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Apple sign-in failed: ${e.toString()}')),
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                      ),

                      SizedBox(height: 6.h),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to our creative world? ',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          GestureDetector(
                            onTap: _navigateToRegister,
                            child: Text(
                              'Join us',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
