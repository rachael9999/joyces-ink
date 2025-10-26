import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class ThirdPartyIntegrationsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> thirdPartyServices;
  final Function(int index, bool connected) onServiceToggle;

  const ThirdPartyIntegrationsWidget({
    Key? key,
    required this.thirdPartyServices,
    required this.onServiceToggle,
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
                  Icons.link,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Third-party Integrations',
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

            if (thirdPartyServices.isEmpty) ...[
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
                      Icons.info_outline,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'No third-party services are currently integrated.',
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
            ] else ...[
              ...thirdPartyServices.asMap().entries.map((entry) {
                final index = entry.key;
                final service = entry.value;
                final isConnected = service['connected'] as bool;
                final serviceName = service['name'] as String;
                final description = service['description'] as String;
                final dataShared = service['dataShared'] as List<String>;
                final icon = service['icon'] as IconData;

                return Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isConnected
                            ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : (isDark
                                ? AppTheme.dividerDark
                                : AppTheme.dividerLight),
                        width: isConnected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isConnected
                          ? (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.05)
                          : Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? (isDark
                                        ? AppTheme.primaryDark
                                        : AppTheme.primaryLight)
                                    : (isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceName,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
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
                              value: isConnected,
                              onChanged: (value) =>
                                  onServiceToggle(index, value),
                            ),
                          ],
                        ),
                        if (isConnected) ...[
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppTheme.primaryDark
                                      : AppTheme.primaryLight)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.share,
                                      size: 4.w,
                                      color: isDark
                                          ? AppTheme.primaryDark
                                          : AppTheme.primaryLight,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Data Shared with $serviceName',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppTheme.textPrimaryDark
                                            : AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Wrap(
                                  spacing: 2.w,
                                  runSpacing: 1.h,
                                  children: dataShared.map((data) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.surfaceDark
                                            : AppTheme.surfaceLight,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isDark
                                              ? AppTheme.dividerDark
                                              : AppTheme.dividerLight,
                                        ),
                                      ),
                                      child: Text(
                                        data,
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          color: isDark
                                              ? AppTheme.textSecondaryDark
                                              : AppTheme.textSecondaryLight,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showDataSharingDetails(
                                      context, serviceName, dataShared),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isDark
                                          ? AppTheme.primaryDark
                                          : AppTheme.primaryLight,
                                    ),
                                  ),
                                  child: Text(
                                    'View Details',
                                    style: GoogleFonts.inter(fontSize: 12.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      onServiceToggle(index, false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorLight,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'Revoke Access',
                                    style: GoogleFonts.inter(fontSize: 12.sp),
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
              }).toList(),
            ],

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
                      'You can revoke access for any connected service at any time. This will stop data sharing but may limit some features.',
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

  void _showDataSharingDetails(
      BuildContext context, String serviceName, List<String> dataShared) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$serviceName Data Sharing',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The following data types are shared with $serviceName:',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 2.h),
              ...dataShared.map((data) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 4.w,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          data,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 2.h),
              Text(
                'This data is used to enhance your experience with $serviceName features. You can revoke access at any time.',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
