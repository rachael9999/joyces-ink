import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryGenerationButtonWidget extends StatelessWidget {
  final bool isGenerating;
  final String? selectedGenre;
  final VoidCallback onGenerate;

  const StoryGenerationButtonWidget({
    Key? key,
    required this.isGenerating,
    this.selectedGenre,
    required this.onGenerate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canGenerate = selectedGenre != null && !isGenerating;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: canGenerate ? onGenerate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canGenerate ? AppTheme.primaryLight : AppTheme.textDisabledLight,
          foregroundColor: AppTheme.onPrimaryLight,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canGenerate ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGenerating) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.onPrimaryLight,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
            ] else ...[
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: AppTheme.onPrimaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
            ],
            Text(
              isGenerating ? 'Generating Story...' : 'Generate Story',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.onPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
