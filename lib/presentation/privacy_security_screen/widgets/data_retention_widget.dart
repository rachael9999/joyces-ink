import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class DataRetentionWidget extends StatelessWidget {
  final String retentionPeriod;
  final Function(String) onRetentionChanged;

  const DataRetentionWidget({
    Key? key,
    required this.retentionPeriod,
    required this.onRetentionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final retentionOptions = [
      {
        'value': '7',
        'label': '7 days',
        'description': 'Quick cleanup, minimal recovery time'
      },
      {
        'value': '30',
        'label': '30 days',
        'description': 'Balanced approach, recommended for most users'
      },
      {
        'value': '90',
        'label': '90 days',
        'description': 'Extended recovery period'
      },
      {
        'value': 'never',
        'label': 'Never delete',
        'description': 'Deleted items remain recoverable indefinitely'
      },
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
                  Icons.schedule_send,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Data Retention',
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
            SizedBox(height: 2.h),

            Text(
              'How long should deleted content remain recoverable?',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 3.h),

            ...retentionOptions.map((option) {
              final isSelected = retentionPeriod == option['value'];

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: InkWell(
                  onTap: () => onRetentionChanged(option['value']!),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : (isDark
                                ? AppTheme.dividerDark
                                : AppTheme.dividerLight),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option['value']!,
                          groupValue: retentionPeriod,
                          onChanged: (value) {
                            if (value != null) onRetentionChanged(value);
                          },
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          _getRetentionIcon(option['value']!),
                          color: isSelected
                              ? (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
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
                                option['label']!,
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
                                option['description']!,
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
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: 3.h),

            // Current Setting Display
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Current Setting',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _getCurrentSettingDescription(),
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

            SizedBox(height: 3.h),

            // Security Notice
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
                    Icons.security,
                    size: 5.w,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'This setting only applies to items you delete. Your active journal entries and stories are always preserved.',
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
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRetentionIcon(String period) {
    switch (period) {
      case '7':
        return Icons.flash_on;
      case '30':
        return Icons.schedule;
      case '90':
        return Icons.history;
      case 'never':
        return Icons.all_inclusive;
      default:
        return Icons.schedule;
    }
  }

  String _getCurrentSettingDescription() {
    switch (retentionPeriod) {
      case '7':
        return 'Deleted items will be permanently removed after 7 days. This provides quick cleanup while allowing short-term recovery.';
      case '30':
        return 'Deleted items will be permanently removed after 30 days. This is the recommended setting for most users.';
      case '90':
        return 'Deleted items will be permanently removed after 90 days. This provides extended recovery time for important content.';
      case 'never':
        return 'Deleted items will remain recoverable indefinitely. Note that this may use more storage space over time.';
      default:
        return 'Default retention period of 30 days is applied.';
    }
  }
}
