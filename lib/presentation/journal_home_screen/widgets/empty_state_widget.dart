import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateEntry;

  const EmptyStateWidget({
    Key? key,
    required this.onCreateEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1455390582262-044cdead277a?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8d3JpdGluZ3xlbnwwfHwwfHx8MA%3D%3D',
              width: 50.w,
              height: 25.h,
              fit: BoxFit.contain,
              semanticLabel:
                  'Illustration of an open notebook with a pen lying on top, surrounded by scattered paper sheets on a wooden desk',
            ),
            SizedBox(height: 4.h),
            Text(
              'Start Your Writing Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Capture your thoughts, experiences, and emotions. Transform them into beautiful stories that reflect your unique perspective.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCreateEntry,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Start Your First Entry',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
