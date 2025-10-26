import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../login_screen/widgets/social_login_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/terms_checkbox_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await AuthService.instance.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _fullNameController.text.trim(),
        );

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Registration successful! Please check your email for verification.'),
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      } catch (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${error.toString()}')),
          );
        }
      }
    }
  }

  void _navigateToLogin() {
    // Use named route constant to avoid typos and keep routes consistent
    Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
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
              child: Column(
                children: [
                  // Back Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _navigateToLogin,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowLight,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),

                          // Header
                          Text(
                            'Join Our Creative Community',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 1.h),

                          Text(
                            'Begin your storytelling adventure today',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 4.h),

                          // Registration Form Card
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
                            child: RegistrationFormWidget(
                              formKey: _formKey,
                              fullNameController: _fullNameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmPasswordController:
                                  _confirmPasswordController,
                              obscurePassword: _obscurePassword,
                              obscureConfirmPassword: _obscureConfirmPassword,
                              isLoading: _isLoading,
                              acceptTerms: _acceptTerms,
                              onTogglePasswordVisibility: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              onToggleConfirmPasswordVisibility: () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                );
                              },
                              onRegister: _handleRegistration,
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Terms and Conditions
                          TermsCheckboxWidget(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() => _acceptTerms = value ?? false);
                            },
                          ),

                          SizedBox(height: 4.h),

                          // Social Registration Section
                          SocialLoginWidget(
                            onGoogleLogin: () {},
                            onAppleLogin: () {},
                          ),

                          SizedBox(height: 6.h),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already part of our story? ',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              GestureDetector(
                                onTap: _navigateToLogin,
                                child: Text(
                                  'Sign In',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
