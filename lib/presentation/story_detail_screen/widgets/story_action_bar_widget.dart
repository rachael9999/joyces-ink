import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryActionBarWidget extends StatelessWidget {
  final bool isFavorite;
  final int rating;
  final VoidCallback onShare;
  final VoidCallback onFavoriteToggle;
  final Function(int) onRatingChanged;
  final VoidCallback onCreateNewVersion;

  const StoryActionBarWidget({
    Key? key,
    required this.isFavorite,
    required this.rating,
    required this.onShare,
    required this.onFavoriteToggle,
    required this.onRatingChanged,
    required this.onCreateNewVersion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rating Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Column(
                children: [
                  Text(
                    'Rate this story',
                    style: AppTheme.lightTheme.textTheme.labelMedium,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => onRatingChanged(index + 1),
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          child: CustomIconWidget(
                            iconName: index < rating ? 'star' : 'star_border',
                            color: index < rating
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                            size: 24,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: 'share',
                    label: 'Share',
                    onTap: onShare,
                    isPrimary: false,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildActionButton(
                    icon: isFavorite ? 'favorite' : 'favorite_border',
                    label: isFavorite ? 'Favorited' : 'Favorite',
                    onTap: onFavoriteToggle,
                    isPrimary: false,
                    iconColor: isFavorite ? Colors.red : null,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    icon: 'refresh',
                    label: 'Create New Version',
                    onTap: onCreateNewVersion,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: iconColor ??
                  (isPrimary
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface),
              size: 20,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isPrimary
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
