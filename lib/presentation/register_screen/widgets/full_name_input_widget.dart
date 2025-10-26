import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FullNameInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;

  const FullNameInputWidget({
    Key? key,
    required this.controller,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FullNameInputWidget> createState() => _FullNameInputWidgetState();
}

class _FullNameInputWidgetState extends State<FullNameInputWidget>
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

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().split(' ').length < 2) {
      return 'Please enter your first and last name';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
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
              'Full Name',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              controller: widget.controller,
              enabled: widget.enabled,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: _validateFullName,
              onChanged: (value) {
                if (_hasError && _validateFullName(value) == null) {
                  setState(() => _hasError = false);
                  _animationController.reverse();
                }
              },
              onTap: () => _animationController.forward(),
              onTapOutside: (event) => _animationController.reverse(),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'person',
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
