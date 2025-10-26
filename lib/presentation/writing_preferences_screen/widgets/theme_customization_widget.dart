import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ThemeCustomizationWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const ThemeCustomizationWidget({super.key, required this.onChanged});

  @override
  State<ThemeCustomizationWidget> createState() =>
      _ThemeCustomizationWidgetState();
}

class _ThemeCustomizationWidgetState extends State<ThemeCustomizationWidget> {
  String _themeMode = 'system';
  Color _primaryColor = const Color(0xFF6366F1);
  Color _accentColor = const Color(0xFF8B5CF6);
  String _fontTheme = 'modern';
  bool _darkModeAuto = true;
  TimeOfDay _darkModeStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _darkModeEndTime = const TimeOfDay(hour: 6, minute: 0);
  double _borderRadius = 12.0;
  bool _customBackground = false;
  String _backgroundStyle = 'subtle';

  final List<Map<String, dynamic>> _themeModes = [
    {
      'value': 'light',
      'label': 'Light Mode',
      'description': 'Always use light theme',
      'icon': Icons.light_mode,
      'color': Colors.amber,
    },
    {
      'value': 'dark',
      'label': 'Dark Mode',
      'description': 'Always use dark theme',
      'icon': Icons.dark_mode,
      'color': Colors.indigo,
    },
    {
      'value': 'system',
      'label': 'System Default',
      'description': 'Follow system settings',
      'icon': Icons.settings_system_daydream,
      'color': Colors.green,
    },
    {
      'value': 'auto',
      'label': 'Auto Schedule',
      'description': 'Switch based on time',
      'icon': Icons.schedule,
      'color': Colors.orange,
    },
  ];

  final List<Color> _colorOptions = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFFEF4444), // Red
    const Color(0xFFF97316), // Orange
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF10B981), // Emerald
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF6366F1), // Indigo
  ];

  final List<Map<String, String>> _fontThemes = [
    {
      'value': 'modern',
      'label': 'Modern',
      'description': 'Inter + Playfair Display',
    },
    {
      'value': 'classic',
      'label': 'Classic',
      'description': 'Roboto + Roboto Slab',
    },
    {
      'value': 'elegant',
      'label': 'Elegant',
      'description': 'Lato + Crimson Text',
    },
    {'value': 'casual', 'label': 'Casual', 'description': 'Open Sans + Nunito'},
  ];

  final List<Map<String, String>> _backgroundStyles = [
    {
      'value': 'subtle',
      'label': 'Subtle Pattern',
      'description': 'Light texture',
    },
    {
      'value': 'gradient',
      'label': 'Gradient',
      'description': 'Smooth color blend',
    },
    {
      'value': 'solid',
      'label': 'Solid Color',
      'description': 'Plain background',
    },
    {
      'value': 'nature',
      'label': 'Nature Inspired',
      'description': 'Organic patterns',
    },
  ];

  Widget _buildThemeModeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Mode',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _themeModes.map((mode) {
                final isSelected = _themeMode == mode['value'];
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isSelected ? theme.primaryColor : theme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isSelected
                            ? theme.primaryColor.withAlpha(13)
                            : Colors.transparent,
                  ),
                  child: RadioListTile<String>(
                    value: mode['value'],
                    groupValue: _themeMode,
                    onChanged: (newValue) {
                      setState(() {
                        _themeMode = newValue!;
                      });
                      widget.onChanged();
                    },
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: mode['color'].withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            mode['icon'],
                            size: 4.w,
                            color: mode['color'],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode['label'],
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? theme.primaryColor
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              mode['description'],
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required String title,
    required Color selectedColor,
    required Function(Color) onColorChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 2.w,
          children:
              _colorOptions.map((color) {
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    onColorChanged(color);
                    widget.onChanged();
                  },
                  child: Container(
                    width: 12.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  Future<void> _selectTime({
    required TimeOfDay initialTime,
    required Function(TimeOfDay) onTimeSelected,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      onTimeSelected(picked);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme Customization',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.palette_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Theme Mode Selection
            _buildThemeModeSelector(),

            if (_themeMode == 'auto') ...[
              SizedBox(height: 3.h),

              // Auto Schedule Settings
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.nights_stay, size: 4.w),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Dark Mode Start Time',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(_darkModeStartTime),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        IconButton(
                          onPressed:
                              () => _selectTime(
                                initialTime: _darkModeStartTime,
                                onTimeSelected:
                                    (time) => setState(() {
                                      _darkModeStartTime = time;
                                    }),
                              ),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),

                    Divider(height: 3.h),

                    Row(
                      children: [
                        Icon(Icons.wb_sunny, size: 4.w),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Light Mode Start Time',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(_darkModeEndTime),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        IconButton(
                          onPressed:
                              () => _selectTime(
                                initialTime: _darkModeEndTime,
                                onTimeSelected:
                                    (time) => setState(() {
                                      _darkModeEndTime = time;
                                    }),
                              ),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 3.h),

            // Color Customization
            _buildColorPicker(
              title: 'Primary Color',
              selectedColor: _primaryColor,
              onColorChanged:
                  (color) => setState(() {
                    _primaryColor = color;
                  }),
            ),

            SizedBox(height: 3.h),

            _buildColorPicker(
              title: 'Accent Color',
              selectedColor: _accentColor,
              onColorChanged:
                  (color) => setState(() {
                    _accentColor = color;
                  }),
            ),

            SizedBox(height: 3.h),

            // Font Theme Selection
            Text(
              'Font Theme',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _fontTheme,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 2.h,
                ),
                prefixIcon: const Icon(Icons.font_download),
              ),
              items:
                  _fontThemes.map((font) {
                    return DropdownMenuItem<String>(
                      value: font['value'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            font['label']!,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            font['description']!,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _fontTheme = value!;
                });
                widget.onChanged();
              },
            ),

            SizedBox(height: 3.h),

            // Border Radius Customization
            Text(
              'Corner Roundness: ${_borderRadius.round()}px',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Slider(
              value: _borderRadius,
              min: 0,
              max: 24,
              divisions: 24,
              onChanged: (value) {
                setState(() {
                  _borderRadius = value;
                });
                widget.onChanged();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sharp',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Very Round',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Background Customization
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.wallpaper, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custom Background',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Use custom background patterns',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _customBackground,
                        onChanged: (value) {
                          setState(() {
                            _customBackground = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  if (_customBackground) ...[
                    SizedBox(height: 2.h),
                    DropdownButtonFormField<String>(
                      initialValue: _backgroundStyle,
                      decoration: const InputDecoration(
                        labelText: 'Background Style',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _backgroundStyles.map((style) {
                            return DropdownMenuItem<String>(
                              value: style['value'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    style['label']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    style['description']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _backgroundStyle = value!;
                        });
                        widget.onChanged();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
