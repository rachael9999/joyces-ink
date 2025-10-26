import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileStatsWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileStatsWidget({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Writing Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 3.h),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Writing Streak',
                  '${userData['writingStreak'] ?? 0} days',
                  'local_fire_department',
                  AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Entries',
                  '${userData['totalEntries'] ?? 0}',
                  'article',
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Stories Generated',
                  '${userData['storiesGenerated'] ?? 0}',
                  'auto_stories',
                  AppTheme.lightTheme.colorScheme.secondaryContainer,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Favorite Genres',
                  _formatGenres(userData['favoriteGenres']),
                  'favorite',
                  AppTheme.lightTheme.colorScheme.primaryContainer,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Writing Goal Progress
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Goal Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                    ),
                    Text(
                      '${userData['dailyGoal'] ?? 300} words',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                LinearProgressIndicator(
                  value: 0.7, // Mock progress
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '210 / ${userData['dailyGoal'] ?? 300} words today',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String iconName,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 6.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  String _formatGenres(List<dynamic>? genres) {
    if (genres == null || genres.isEmpty) return '0';
    if (genres.length == 1) return genres.first;
    return '${genres.length} genres';
  }
}
