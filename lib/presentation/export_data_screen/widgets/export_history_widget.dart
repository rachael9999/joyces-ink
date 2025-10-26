import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class ExportHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exportHistory;
  final Function(Map<String, dynamic>) onRedownload;

  const ExportHistoryWidget({
    Key? key,
    required this.exportHistory,
    required this.onRedownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (exportHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export History',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            ...exportHistory.map((item) {
              final date = item['date'] as DateTime;
              final format = item['format'] as String;
              final size = item['size'] as String;
              final status = item['status'] as String;
              final filename = item['filename'] as String;

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status, isDark)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getStatusColor(status, isDark),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              format,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(status, isDark),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status, isDark)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 3.w,
                                  color: _getStatusColor(status, isDark),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  status.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(status, isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        filename,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 4.w,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            _formatExportDate(date),
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.folder,
                            size: 4.w,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            size,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const Spacer(),
                          if (status == 'completed')
                            TextButton.icon(
                              onPressed: () => onRedownload(item),
                              icon: Icon(
                                Icons.download,
                                size: 4.w,
                              ),
                              label: Text(
                                'Re-download',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (status == 'expired') ...[
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.errorLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 4.w,
                                color: AppTheme.errorLight,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  'This export has expired and is no longer available for download.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: AppTheme.errorLight,
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
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'completed':
        return isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
      case 'expired':
        return AppTheme.errorLight;
      case 'processing':
        return isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight;
      default:
        return isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'expired':
        return Icons.error;
      case 'processing':
        return Icons.hourglass_empty;
      default:
        return Icons.info;
    }
  }

  String _formatExportDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
