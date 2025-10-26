import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WritingStreakWidget extends StatelessWidget {
  final int streakCount;
  final int totalEntries;

  const WritingStreakWidget({
    Key? key,
    required this.streakCount,
    required this.totalEntries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'local_fire_department',
              color: Colors.white,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Writing Streak',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      '$streakCount days',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '• $totalEntries entries',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
