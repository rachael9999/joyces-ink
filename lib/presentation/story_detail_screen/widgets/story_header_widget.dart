import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryHeaderWidget extends StatelessWidget {
  final String title;
  final bool isEditing;
  final Function(String) onTitleChanged;
  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;

  const StoryHeaderWidget({
    Key? key,
    required this.title,
    required this.isEditing,
    required this.onTitleChanged,
    required this.onBackPressed,
    required this.onMenuPressed,
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
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: isEditing
                  ? TextFormField(
                      initialValue: title,
                      onChanged: onTitleChanged,
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Enter story title...',
                        hintStyle:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      maxLines: 1,
                    )
                  : Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: onMenuPressed,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
