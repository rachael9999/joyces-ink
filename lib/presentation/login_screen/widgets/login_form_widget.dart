import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './email_input_widget.dart';
import './password_input_widget.dart';

class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const LoginFormWidget({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'Continue your creative journey',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Email Input
          EmailInputWidget(controller: emailController, enabled: !isLoading),

          SizedBox(height: 3.h),

          // Password Input
          PasswordInputWidget(
            controller: passwordController,
            obscureText: obscurePassword,
            enabled: !isLoading,
            onToggleVisibility: onTogglePasswordVisibility,
          ),

          SizedBox(height: 2.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: isLoading ? null : onForgotPassword,
              child: Text(
                'Forgot your password?',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Sign In Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.3,
                    );
                  }
                  return AppTheme.lightTheme.colorScheme.primary;
                }),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child:
                  isLoading
                      ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                      : Text(
                        'Sign In',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
