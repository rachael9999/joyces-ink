import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsCheckboxWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsCheckboxWidget({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms of Service',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Welcome to joycesink, where creativity flows freely. By using our service, you agree to these terms:\n\n'
              '• Your stories and journals remain your intellectual property\n'
              '• We use AI to help transform your entries into stories\n'
              '• Your data is encrypted and secure\n'
              '• You can export or delete your content anytime\n'
              '• We respect your creative privacy\n\n'
              'Our mission is to empower your storytelling journey while keeping your content safe and private.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Policy',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Your privacy is our priority at joycesink:\n\n'
              '• We collect only essential data for account creation\n'
              '• Your journal entries are encrypted end-to-end\n'
              '• AI processing happens securely without data retention\n'
              '• We never share your personal content with third parties\n'
              '• You control your data - export or delete anytime\n'
              '• Optional analytics help improve our service (can be disabled)\n\n'
              'We believe creativity flourishes in a secure, private environment.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 6.w,
            height: 6.w,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => _showTermsDialog(context),
                          child: Text(
                            'Terms of Service',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => _showPrivacyDialog(context),
                          child: Text(
                            'Privacy Policy',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your creative content remains private and secure',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
