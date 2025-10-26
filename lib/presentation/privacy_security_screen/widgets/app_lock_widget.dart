import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class AppLockWidget extends StatelessWidget {
  final bool appLockEnabled;
  final String lockTimeout;
  final bool hideContentInSwitcher;
  final Function(bool) onAppLockToggle;
  final Function(String) onTimeoutChanged;
  final Function(bool) onHideContentToggle;

  const AppLockWidget({
    Key? key,
    required this.appLockEnabled,
    required this.lockTimeout,
    required this.hideContentInSwitcher,
    required this.onAppLockToggle,
    required this.onTimeoutChanged,
    required this.onHideContentToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final timeoutOptions = [
      {'value': 'immediate', 'label': 'Immediately'},
      {'value': '30seconds', 'label': 'After 30 seconds'},
      {'value': '1minute', 'label': 'After 1 minute'},
      {'value': '5minutes', 'label': 'After 5 minutes'},
      {'value': '15minutes', 'label': 'After 15 minutes'},
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock,
                  color: appLockEnabled
                      ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      : (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
                ),
                SizedBox(width: 3.w),
                Text(
                  'App Lock Settings',
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

            // App Lock Toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable App Lock',
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
                        'Require authentication when opening the app',
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
                  value: appLockEnabled,
                  onChanged: onAppLockToggle,
                ),
              ],
            ),

            if (appLockEnabled) ...[
              SizedBox(height: 3.h),

              // Lock Timeout Settings
              Text(
                'Lock Timeout',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 2.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: lockTimeout,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                    items: timeoutOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Text(
                          option['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onTimeoutChanged(value);
                    },
                    dropdownColor:
                        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Hide Content in App Switcher
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hide Content in App Switcher',
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
                          'Blur or hide sensitive content when switching between apps',
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
                    value: hideContentInSwitcher,
                    onChanged: onHideContentToggle,
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Security Info
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enhanced Security',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'App lock works with your device\'s security features including biometrics, PIN, pattern, or password.',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_open,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Enable app lock to add an extra layer of security to your journal entries and generated stories.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
