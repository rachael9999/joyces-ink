import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class DateRangePickerWidget extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final String datePreset;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(String) onPresetChanged;

  const DateRangePickerWidget({
    Key? key,
    required this.selectedDateRange,
    required this.datePreset,
    required this.onDateRangeChanged,
    required this.onPresetChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final presetOptions = [
      {'value': 'all', 'label': 'All Time'},
      {'value': 'lastMonth', 'label': 'Last Month'},
      {'value': 'lastYear', 'label': 'Last Year'},
      {'value': 'custom', 'label': 'Custom Range'},
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range Filter',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),

            // Preset Options
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: presetOptions.map((option) {
                final isSelected = datePreset == option['value'];

                return FilterChip(
                  selected: isSelected,
                  label: Text(
                    option['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (isDark
                              ? AppTheme.onPrimaryDark
                              : AppTheme.onPrimaryLight)
                          : (isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      onPresetChanged(option['value']!);
                    }
                  },
                  selectedColor:
                      isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: isSelected
                        ? (isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight)
                        : (isDark
                            ? AppTheme.dividerDark
                            : AppTheme.dividerLight),
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
            ),

            // Custom Date Range Selector
            if (datePreset == 'custom') ...[
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          selectedDateRange != null
                              ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                              : 'Select date range',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final dateRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDateRange: selectedDateRange,
                              builder: (context, child) {
                                return Theme(
                                  data: theme,
                                  child: child!,
                                );
                              },
                            );

                            if (dateRange != null) {
                              onDateRangeChanged(dateRange);
                            }
                          },
                          child: Text(
                            selectedDateRange != null ? 'Change' : 'Select',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Selected Range Display
            if (selectedDateRange != null && datePreset != 'custom') ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 4.w,
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Range: ${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}',
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
