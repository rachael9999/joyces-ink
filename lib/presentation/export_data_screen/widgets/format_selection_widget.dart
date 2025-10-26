import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class FormatSelectionWidget extends StatelessWidget {
  final List<String> formatOptions;
  final String selectedFormat;
  final Function(String) onFormatChanged;

  const FormatSelectionWidget({
    Key? key,
    required this.formatOptions,
    required this.selectedFormat,
    required this.onFormatChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formatDescriptions = {
      'JSON': 'Complete structured data with full compatibility',
      'PDF': 'Human-readable document format for sharing',
      'ZIP': 'Compressed archive containing all selected data',
      'CSV': 'Spreadsheet-compatible format for data analysis',
    };

    final formatIcons = {
      'JSON': Icons.data_object,
      'PDF': Icons.picture_as_pdf,
      'ZIP': Icons.archive,
      'CSV': Icons.table_chart,
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            ...formatOptions.map((format) {
              final isSelected = selectedFormat == format;

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: InkWell(
                  onTap: () => onFormatChanged(format),
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
                          value: format,
                          groupValue: selectedFormat,
                          onChanged: (value) {
                            if (value != null) onFormatChanged(value);
                          },
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          formatIcons[format] ?? Icons.file_present,
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
                                format,
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
                                formatDescriptions[format] ?? '',
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
          ],
        ),
      ),
    );
  }
}
