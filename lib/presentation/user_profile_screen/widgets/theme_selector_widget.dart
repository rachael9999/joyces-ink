import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThemeSelectorWidget extends StatelessWidget {
  final String selectedTheme;
  final ValueChanged<String> onThemeChanged;

  const ThemeSelectorWidget({
    Key? key,
    required this.selectedTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: 'palette',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
      ),
      title: Text(
        'Theme',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        selectedTheme,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
      ),
      children: [
        _buildThemeOption(
          context,
          'Light',
          'Bright and clean interface',
          'light_mode',
          selectedTheme == 'Light',
        ),
        _buildThemeOption(
          context,
          'Dark',
          'Easy on the eyes in low light',
          'dark_mode',
          selectedTheme == 'Dark',
        ),
        _buildThemeOption(
          context,
          'System',
          'Follows device settings',
          'settings_brightness',
          selectedTheme == 'System',
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    bool isSelected,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            )
          : null,
      onTap: () => onThemeChanged(title),
    );
  }
}
