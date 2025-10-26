import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NewEntryCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const NewEntryCardWidget({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            gradient: AppTheme.storyGenerationGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'mic',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                'New Entry',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Capture your thoughts and transform them into stories',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
