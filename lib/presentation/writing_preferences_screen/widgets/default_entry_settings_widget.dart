import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class DefaultEntrySettingsWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const DefaultEntrySettingsWidget({super.key, required this.onChanged});

  @override
  State<DefaultEntrySettingsWidget> createState() =>
      _DefaultEntrySettingsWidgetState();
}

class _DefaultEntrySettingsWidgetState
    extends State<DefaultEntrySettingsWidget> {
  String _defaultMood = 'neutral';
  bool _includeLocation = true;
  bool _includeWeather = false;
  bool _autoSaveEnabled = true;
  int _autoSaveInterval = 30; // seconds
  String _defaultPrivacy = 'private';

  final List<Map<String, dynamic>> _moods = [
    {'value': 'happy', 'label': 'Happy', 'emoji': '😊', 'color': Colors.yellow},
    {'value': 'sad', 'label': 'Sad', 'emoji': '😢', 'color': Colors.blue},
    {
      'value': 'excited',
      'label': 'Excited',
      'emoji': '🤩',
      'color': Colors.orange,
    },
    {'value': 'calm', 'label': 'Calm', 'emoji': '😌', 'color': Colors.green},
    {
      'value': 'neutral',
      'label': 'Neutral',
      'emoji': '😐',
      'color': Colors.grey,
    },
    {
      'value': 'anxious',
      'label': 'Anxious',
      'emoji': '😰',
      'color': Colors.purple,
    },
  ];

  Widget _buildMoodSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Mood',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children:
              _moods.map((mood) {
                final isSelected = _defaultMood == mood['value'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _defaultMood = mood['value'];
                    });
                    widget.onChanged();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? mood['color'].withAlpha(51)
                              : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? mood['color'] : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood['emoji'], style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: 2.w),
                        Text(
                          mood['label'],
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected
                                    ? mood['color']
                                    : theme.colorScheme.onSurface,
                          ),
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

  Widget _buildPrivacySelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Privacy Setting',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'private',
                groupValue: _defaultPrivacy,
                onChanged: (value) {
                  setState(() {
                    _defaultPrivacy = value!;
                  });
                  widget.onChanged();
                },
                title: Row(
                  children: [
                    Icon(Icons.lock, size: 4.w, color: Colors.red.shade600),
                    SizedBox(width: 2.w),
                    Text(
                      'Private',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'public',
                groupValue: _defaultPrivacy,
                onChanged: (value) {
                  setState(() {
                    _defaultPrivacy = value!;
                  });
                  widget.onChanged();
                },
                title: Row(
                  children: [
                    Icon(Icons.public, size: 4.w, color: Colors.green.shade600),
                    SizedBox(width: 2.w),
                    Text(
                      'Public',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
                  'Default Entry Settings',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.settings_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Mood Selector
            _buildMoodSelector(),

            SizedBox(height: 3.h),

            // Location and Weather Settings
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
                      Icon(Icons.location_on_outlined, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Include Location',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Add location data to entries automatically',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _includeLocation,
                        onChanged: (value) {
                          setState(() {
                            _includeLocation = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Include Weather',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Add current weather to entries',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _includeWeather,
                        onChanged: (value) {
                          setState(() {
                            _includeWeather = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Auto-Save Settings
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.save_outlined, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-Save',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Automatically save entries while writing',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _autoSaveEnabled,
                        onChanged: (value) {
                          setState(() {
                            _autoSaveEnabled = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  if (_autoSaveEnabled) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Auto-Save Interval: ${_autoSaveInterval}s',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _autoSaveInterval.toDouble(),
                      min: 10,
                      max: 120,
                      divisions: 11,
                      onChanged: (value) {
                        setState(() {
                          _autoSaveInterval = value.round();
                        });
                        widget.onChanged();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '10s',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '2m',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Privacy Settings
            _buildPrivacySelector(),
          ],
        ),
      ),
    );
  }
}
