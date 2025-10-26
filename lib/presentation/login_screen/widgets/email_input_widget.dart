import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmailInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;

  const EmailInputWidget({
    Key? key,
    required this.controller,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<EmailInputWidget> createState() => _EmailInputWidgetState();
}

class _EmailInputWidgetState extends State<EmailInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _borderColorAnimation = ColorTween(
      begin: AppTheme.lightTheme.dividerColor,
      end: AppTheme.lightTheme.colorScheme.primary,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: widget.controller,
              enabled: widget.enabled,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              onChanged: (value) {
                if (_hasError && _validateEmail(value) == null) {
                  setState(() => _hasError = false);
                  _animationController.reverse();
                }
              },
              onTap: () => _animationController.forward(),
              onTapOutside: (event) => _animationController.reverse(),
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color:
                        _hasError
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        _borderColorAnimation.value ??
                        AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.error,
                    width: 2,
                  ),
                ),
                errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
