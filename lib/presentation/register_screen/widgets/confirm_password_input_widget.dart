import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConfirmPasswordInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool obscureText;
  final bool enabled;
  final VoidCallback onToggleVisibility;

  const ConfirmPasswordInputWidget({
    Key? key,
    required this.controller,
    required this.passwordController,
    required this.obscureText,
    required this.onToggleVisibility,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ConfirmPasswordInputWidget> createState() =>
      _ConfirmPasswordInputWidgetState();
}

class _ConfirmPasswordInputWidgetState extends State<ConfirmPasswordInputWidget>
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != widget.passwordController.text) {
      return 'Passwords do not match';
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
              'Confirm Password',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: widget.controller,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              textInputAction: TextInputAction.done,
              validator: _validateConfirmPassword,
              onChanged: (value) {
                if (_hasError && _validateConfirmPassword(value) == null) {
                  setState(() => _hasError = false);
                  _animationController.reverse();
                }
              },
              onTap: () => _animationController.forward(),
              onTapOutside: (event) => _animationController.reverse(),
              decoration: InputDecoration(
                hintText: 'Confirm your password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock_outline',
                    color:
                        _hasError
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: widget.enabled ? widget.onToggleVisibility : null,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName:
                          widget.obscureText ? 'visibility' : 'visibility_off',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
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
