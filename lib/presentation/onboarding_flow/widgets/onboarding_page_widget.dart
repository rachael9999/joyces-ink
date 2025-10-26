import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String semanticLabel;
  final bool isLastPage;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onGetStarted;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.semanticLabel,
    this.isLastPage = false,
    this.onNext,
    this.onSkip,
    this.onGetStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Column(
          children: [
            // Skip button
            if (!isLastPage)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            if (!isLastPage) SizedBox(height: 2.h),

            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  Container(
                    width: 80.w,
                    height: 35.h,
                    constraints: BoxConstraints(
                      maxWidth: 320,
                      maxHeight: 280,
                    ),
                    child: CustomImageWidget(
                      imageUrl: imageUrl,
                      width: 80.w,
                      height: 35.h,
                      fit: BoxFit.contain,
                      semanticLabel: semanticLabel,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Title
                  Text(
                    title,
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 3.h),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: isLastPage ? onGetStarted : onNext,
                style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                  minimumSize:
                      WidgetStateProperty.all(Size(double.infinity, 6.h)),
                ),
                child: Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
