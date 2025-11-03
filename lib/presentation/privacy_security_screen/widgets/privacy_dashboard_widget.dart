import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class PrivacyDashboardWidget extends StatelessWidget {
  const PrivacyDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data for privacy dashboard
    final privacyStats = {
      'dataExported': '2 times this month',
      'loginAttempts': '1 failed attempt (7 days ago)',
      'locationAccess': '0 times this week',
      'thirdPartySharing': '1 active connection',
      'dataEncryption': 'AES-256 enabled',
      'lastSecurityScan': '2 days ago',
    };

    final recentActivities = [
      {
        'action': 'Security settings updated',
        'time': '2 hours ago',
        'icon': Icons.security,
        'type': 'security',
      },
      {
        'action': 'Data export completed',
        'time': '1 day ago',
        'icon': Icons.download,
        'type': 'data',
      },
      {
        'action': 'App lock enabled',
        'time': '3 days ago',
        'icon': Icons.lock,
        'type': 'security',
      },
      {
        'action': 'Privacy policy updated',
        'time': '1 week ago',
        'icon': Icons.policy,
        'type': 'policy',
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
                  Icons.dashboard,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Privacy Dashboard',
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

            // Privacy Statistics
            Text(
              'Data Usage Summary',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard(
                  icon: Icons.cloud_download,
                  label: 'Data Exports',
                  value: privacyStats['dataExported']!,
                  isDark: isDark,
                ),
                _buildStatCard(
                  icon: Icons.login,
                  label: 'Login Security',
                  value: privacyStats['loginAttempts']!,
                  isDark: isDark,
                ),
                _buildStatCard(
                  icon: Icons.location_on,
                  label: 'Location Access',
                  value: privacyStats['locationAccess']!,
                  isDark: isDark,
                ),
                _buildStatCard(
                  icon: Icons.link,
                  label: 'Connections',
                  value: privacyStats['thirdPartySharing']!,
                  isDark: isDark,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Security Status
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: Colors.green,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Status: Excellent',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${privacyStats['dataEncryption']} • Last scan: ${privacyStats['lastSecurityScan']}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.green.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Recent Privacy Activities
            Text(
              'Recent Privacy Activities',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),

            ...recentActivities.take(3).map((activity) {
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getActivityColor(activity['type'] as String)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: _getActivityColor(activity['type'] as String),
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['action'] as String,
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
                            activity['time'] as String,
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
              );
            }).toList(),

            SizedBox(height: 2.h),

            // View Full Activity Log
            Center(
              child: TextButton.icon(
                onPressed: () {
                  _showFullActivityLog(context, recentActivities);
                },
                icon: Icon(
                  Icons.history,
                  size: 4.w,
                ),
                label: Text(
                  'View Full Activity Log',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'security':
        return Colors.green;
      case 'data':
        return Colors.blue;
      case 'policy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showFullActivityLog(
      BuildContext context, List<Map<String, dynamic>> activities) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Activity Log',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(activity['type'] as String)
                      .withValues(alpha: 0.1),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: _getActivityColor(activity['type'] as String),
                  ),
                ),
                title: Text(
                  activity['action'] as String,
                  style: GoogleFonts.inter(fontSize: 13.sp),
                ),
                subtitle: Text(
                  activity['time'] as String,
                  style: GoogleFonts.inter(fontSize: 11.sp),
                ),
              );
            },
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
