import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class DataPrivacyWidget extends StatelessWidget {
  final String privacyLevel;
  final bool analyticsSharing;
  final bool crashReporting;
  final bool usageStatistics;
  final Function(String) onPrivacyLevelChanged;
  final Function(bool) onAnalyticsChanged;
  final Function(bool) onCrashReportingChanged;
  final Function(bool) onUsageStatisticsChanged;

  const DataPrivacyWidget({
    Key? key,
    required this.privacyLevel,
    required this.analyticsSharing,
    required this.crashReporting,
    required this.usageStatistics,
    required this.onPrivacyLevelChanged,
    required this.onAnalyticsChanged,
    required this.onCrashReportingChanged,
    required this.onUsageStatisticsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final privacyLevels = {
      'minimal': {
        'title': 'Minimal',
        'description': 'Only essential data collection for core functionality',
        'color': Colors.green,
        'icon': Icons.security,
      },
      'balanced': {
        'title': 'Balanced',
        'description': 'Some data collection to improve app experience',
        'color': Colors.orange,
        'icon': Icons.balance,
      },
      'enhanced': {
        'title': 'Enhanced',
        'description': 'Full data collection for personalized features',
        'color': Colors.blue,
        'icon': Icons.tune,
      },
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Privacy',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),

            // Privacy Level Selection
            Text(
              'Privacy Level',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),

            ...privacyLevels.entries.map((entry) {
              final key = entry.key;
              final level = entry.value;
              final isSelected = privacyLevel == key;

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: InkWell(
                  onTap: () => onPrivacyLevelChanged(key),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? (level['color'] as Color)
                            : (isDark
                                ? AppTheme.dividerDark
                                : AppTheme.dividerLight),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? (level['color'] as Color).withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: key,
                          groupValue: privacyLevel,
                          onChanged: (value) {
                            if (value != null) onPrivacyLevelChanged(value);
                          },
                          activeColor: level['color'] as Color,
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          level['icon'] as IconData,
                          color: isSelected
                              ? (level['color'] as Color)
                              : (isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level['title'] as String,
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
                                level['description'] as String,
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
                    ),
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 3.h),

            // Individual Privacy Controls
            Text(
              'Specific Data Controls',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),

            _buildPrivacyControl(
              icon: Icons.analytics,
              title: 'Analytics Sharing',
              description: 'Help improve the app by sharing usage analytics',
              value: analyticsSharing,
              onChanged: onAnalyticsChanged,
              isDark: isDark,
            ),

            SizedBox(height: 2.h),

            _buildPrivacyControl(
              icon: Icons.bug_report,
              title: 'Crash Reporting',
              description:
                  'Automatically send crash reports to improve stability',
              value: crashReporting,
              onChanged: onCrashReportingChanged,
              isDark: isDark,
            ),

            SizedBox(height: 2.h),

            _buildPrivacyControl(
              icon: Icons.insights,
              title: 'Usage Statistics',
              description: 'Share how you use features to help us improve',
              value: usageStatistics,
              onChanged: onUsageStatisticsChanged,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyControl({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                description,
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
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
