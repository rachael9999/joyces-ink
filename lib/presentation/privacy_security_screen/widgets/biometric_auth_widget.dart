import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class BiometricAuthWidget extends StatelessWidget {
  final bool biometricEnabled;
  final bool biometricAvailable;
  final String biometricType;
  final Function(bool) onBiometricToggle;

  const BiometricAuthWidget({
    Key? key,
    required this.biometricEnabled,
    required this.biometricAvailable,
    required this.biometricType,
    required this.onBiometricToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getBiometricIcon(),
                  color: biometricAvailable
                      ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      : (isDark
                          ? AppTheme.textDisabledDark
                          : AppTheme.textDisabledLight),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Biometric Authentication',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            if (!biometricAvailable) ...[
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorLight,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Biometric authentication is not available on this device or not set up in system settings.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppTheme.errorLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getBiometricTitle(),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Unlock the app using ${_getBiometricDescription()}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: biometricEnabled && biometricAvailable,
                    onChanged: biometricAvailable ? onBiometricToggle : null,
                  ),
                ],
              ),
              if (biometricEnabled) ...[
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color:
                        (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Fallback Authentication',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'If biometric authentication fails, you can use your device PIN, pattern, or password as a backup.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            if (biometricAvailable) ...[
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(
                    Icons.security,
                    size: 4.w,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Your biometric data is stored securely on your device and never shared with Joyce\'s Ink servers.',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    switch (biometricType) {
      case 'face':
        return Icons.face;
      case 'fingerprint':
        return Icons.fingerprint;
      case 'iris':
        return Icons.visibility;
      default:
        return Icons.security;
    }
  }

  String _getBiometricTitle() {
    switch (biometricType) {
      case 'face':
        return 'Face ID';
      case 'fingerprint':
        return 'Fingerprint';
      case 'iris':
        return 'Iris Scan';
      default:
        return 'Biometric Unlock';
    }
  }

  String _getBiometricDescription() {
    switch (biometricType) {
      case 'face':
        return 'your face';
      case 'fingerprint':
        return 'your fingerprint';
      case 'iris':
        return 'iris recognition';
      default:
        return 'biometric authentication';
    }
  }
}
