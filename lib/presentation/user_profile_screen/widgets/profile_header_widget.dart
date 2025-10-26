import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onAvatarTap;

  const ProfileHeaderWidget({
    Key? key,
    required this.userData,
    required this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with edit indicator
          Stack(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 15.w,
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  backgroundImage: userData['avatar'] != null
                      ? NetworkImage(userData['avatar'])
                      : null,
                  child: userData['avatar'] == null
                      ? Text(
                          userData['name']?.substring(0, 1).toUpperCase() ??
                              'U',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      size: 4.w,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // User name
          Text(
            userData['name'] ?? 'Unknown User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Bio
          if (userData['bio'] != null) ...[
            Text(
              userData['bio'],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
          ],

          // Member since
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Member since ${_formatMemberSince(userData['memberSince'])}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMemberSince(DateTime? date) {
    if (date == null) return 'Unknown';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
