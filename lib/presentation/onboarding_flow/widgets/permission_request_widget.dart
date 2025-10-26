import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionRequestWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onTap;

  const PermissionRequestWidget({
    Key? key,
    required this.iconName,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isGranted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isGranted
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isGranted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isGranted
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isGranted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: isGranted
                  ? Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 3.w,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
