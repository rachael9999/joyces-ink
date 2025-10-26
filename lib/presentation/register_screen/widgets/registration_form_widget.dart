import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../login_screen/widgets/email_input_widget.dart';
import '../../login_screen/widgets/password_input_widget.dart';
import './confirm_password_input_widget.dart';
import './full_name_input_widget.dart';

class RegistrationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final bool acceptTerms;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onRegister;

  const RegistrationFormWidget({
    Key? key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.acceptTerms,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Your Account',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'Your creative journey starts here',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Full Name Input
          FullNameInputWidget(
            controller: fullNameController,
            enabled: !isLoading,
          ),

          SizedBox(height: 3.h),

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

          SizedBox(height: 3.h),

          // Confirm Password Input
          ConfirmPasswordInputWidget(
            controller: confirmPasswordController,
            passwordController: passwordController,
            obscureText: obscureConfirmPassword,
            enabled: !isLoading,
            onToggleVisibility: onToggleConfirmPasswordVisibility,
          ),

          SizedBox(height: 4.h),

          // Create Account Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: (isLoading || !acceptTerms) ? null : onRegister,
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
              child: isLoading
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
                      'Create Account',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Terms requirement text
          if (!acceptTerms) ...[
            SizedBox(height: 2.h),
            Text(
              'Please accept the Terms and Conditions to create your account',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
