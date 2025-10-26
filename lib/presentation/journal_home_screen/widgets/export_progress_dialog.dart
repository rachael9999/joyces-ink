import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportProgressDialog extends StatefulWidget {
  const ExportProgressDialog({Key? key}) : super(key: key);

  @override
  State<ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<ExportProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _progress = 0.0;
  String _currentStep = 'Preparing export...';
  bool _isCompleted = false;

  final List<String> _exportSteps = [
    'Preparing export...',
    'Collecting journal entries...',
    'Processing images...',
    'Formatting content...',
    'Generating export file...',
    'Export completed!',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _progressController.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
        int stepIndex = (_progress * (_exportSteps.length - 1)).floor();
        stepIndex = stepIndex.clamp(0, _exportSteps.length - 1);
        _currentStep = _exportSteps[stepIndex];

        if (_progress >= 1.0 && !_isCompleted) {
          _isCompleted = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      const Text('Export completed successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        }
      });
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Export Icon
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: CustomIconWidget(
                  key: ValueKey(_isCompleted ? 'check' : 'download'),
                  iconName: _isCompleted ? 'check_circle' : 'download',
                  color: _isCompleted
                      ? Colors.green
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 12.w,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              _isCompleted ? 'Export Complete!' : 'Exporting Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            SizedBox(height: 2.h),

            // Current Step
            Text(
              _currentStep,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 3.h),

            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '24 entries',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 1.h,
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCompleted
                          ? Colors.green
                          : AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Export Details
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Exporting as PDF with images and metadata included',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            if (_isCompleted) ...[
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('File shared successfully')),
                        );
                      },
                      icon: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 4.w,
                      ),
                      label: const Text('Share'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Opening exported file...')),
                        );
                      },
                      icon: CustomIconWidget(
                        iconName: 'open_in_new',
                        color: Colors.white,
                        size: 4.w,
                      ),
                      label: const Text('Open'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
