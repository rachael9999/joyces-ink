import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;

  const SocialLoginWidget({
    Key? key,
    required this.onGoogleLogin,
    required this.onAppleLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "or" text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.dividerColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'or continue with',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.dividerColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Social Login Buttons
        Row(
          children: [
            // Google Login Button
            Expanded(
              child: _buildSocialButton(
                onTap: onGoogleLogin,
                iconName: 'google',
                label: 'Google',
                backgroundColor: Colors.white,
                borderColor: AppTheme.lightTheme.dividerColor,
                textColor: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),

            SizedBox(width: 3.w),

            // Apple Login Button
            Expanded(
              child: _buildSocialButton(
                onTap: onAppleLogin,
                iconName: 'apple',
                label: 'Apple',
                backgroundColor: Colors.black,
                borderColor: Colors.black,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required String iconName,
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: iconName, size: 5.w, color: textColor),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
