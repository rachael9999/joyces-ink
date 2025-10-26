import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class ExportProgressWidget extends StatelessWidget {
  final double progress;
  final String estimatedTime;

  const ExportProgressWidget({
    Key? key,
    required this.progress,
    required this.estimatedTime,
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
                  Icons.cloud_download,
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Exporting Data...',
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

            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      estimatedTime,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  ),
                  minHeight: 1.5.w,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Progress Steps
            Row(
              children: [
                _buildProgressStep(
                  icon: Icons.check_circle,
                  label: 'Preparing',
                  isCompleted: progress > 0.1,
                  isActive: progress <= 0.1,
                  isDark: isDark,
                ),
                SizedBox(width: 2.w),
                _buildProgressStep(
                  icon: Icons.data_array,
                  label: 'Processing',
                  isCompleted: progress > 0.7,
                  isActive: progress > 0.1 && progress <= 0.7,
                  isDark: isDark,
                ),
                SizedBox(width: 2.w),
                _buildProgressStep(
                  icon: Icons.download,
                  label: 'Downloading',
                  isCompleted: progress >= 1.0,
                  isActive: progress > 0.7 && progress < 1.0,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
    required bool isDark,
  }) {
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      iconColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
      textColor = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    } else if (isActive) {
      iconColor = isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight;
      textColor = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    } else {
      iconColor =
          isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight;
      textColor =
          isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor,
                width: 1,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: iconColor,
              size: 5.w,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
