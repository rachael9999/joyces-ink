import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class DataSelectionWidget extends StatelessWidget {
  final Map<String, bool> dataSelection;
  final Function(String key, bool value) onSelectionChanged;

  const DataSelectionWidget({
    Key? key,
    required this.dataSelection,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dataTypes = {
      'journalEntries': {
        'title': 'Journal Entries',
        'description': 'All your personal journal entries and reflections',
        'icon': Icons.book,
      },
      'generatedStories': {
        'title': 'Generated Stories',
        'description': 'AI-generated stories based on your prompts',
        'icon': Icons.auto_stories,
      },
      'userPreferences': {
        'title': 'User Preferences',
        'description': 'App settings, themes, and personal preferences',
        'icon': Icons.settings,
      },
      'accountInfo': {
        'title': 'Account Information',
        'description': 'Basic account details and profile information',
        'icon': Icons.account_circle,
      },
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Selection',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        for (final key in dataSelection.keys) {
                          onSelectionChanged(key, true);
                        }
                      },
                      child: Text(
                        'Select All',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        for (final key in dataSelection.keys) {
                          onSelectionChanged(key, false);
                        }
                      },
                      child: Text(
                        'Select None',
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
            SizedBox(height: 3.h),
            ...dataTypes.entries.map((entry) {
              final key = entry.key;
              final data = entry.value;
              final isSelected = dataSelection[key] ?? false;

              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: InkWell(
                  onTap: () => onSelectionChanged(key, !isSelected),
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
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) =>
                              onSelectionChanged(key, value ?? false),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          data['icon'] as IconData,
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
                                data['title'] as String,
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
                                data['description'] as String,
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
          ],
        ),
      ),
    );
  }
}
