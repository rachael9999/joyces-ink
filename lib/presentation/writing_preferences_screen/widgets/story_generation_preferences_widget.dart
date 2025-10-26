import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class StoryGenerationPreferencesWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const StoryGenerationPreferencesWidget({super.key, required this.onChanged});

  @override
  State<StoryGenerationPreferencesWidget> createState() =>
      _StoryGenerationPreferencesWidgetState();
}

class _StoryGenerationPreferencesWidgetState
    extends State<StoryGenerationPreferencesWidget> {
  String _preferredGenre = 'adventure';
  String _storyLength = 'medium';
  String _writingStyle = 'descriptive';
  double _creativityLevel = 0.7;
  bool _includeDialogue = true;
  bool _includeCharacterDevelopment = true;
  List<String> _favoriteThemes = ['friendship', 'growth'];

  final List<Map<String, dynamic>> _genres = [
    {'value': 'adventure', 'label': 'Adventure', 'icon': Icons.explore},
    {'value': 'romance', 'label': 'Romance', 'icon': Icons.favorite},
    {'value': 'mystery', 'label': 'Mystery', 'icon': Icons.search},
    {'value': 'fantasy', 'label': 'Fantasy', 'icon': Icons.auto_awesome},
    {'value': 'scifi', 'label': 'Sci-Fi', 'icon': Icons.rocket_launch},
    {'value': 'horror', 'label': 'Horror', 'icon': Icons.nightlight},
  ];

  final List<Map<String, dynamic>> _lengths = [
    {'value': 'short', 'label': 'Short', 'description': '100-300 words'},
    {'value': 'medium', 'label': 'Medium', 'description': '300-800 words'},
    {'value': 'long', 'label': 'Long', 'description': '800+ words'},
  ];

  final List<Map<String, dynamic>> _styles = [
    {
      'value': 'descriptive',
      'label': 'Descriptive',
      'description': 'Rich imagery and details',
    },
    {
      'value': 'dialogue',
      'label': 'Dialogue-Heavy',
      'description': 'Character conversations focused',
    },
    {
      'value': 'action',
      'label': 'Action-Packed',
      'description': 'Fast-paced and dynamic',
    },
    {
      'value': 'contemplative',
      'label': 'Contemplative',
      'description': 'Thoughtful and introspective',
    },
  ];

  final List<String> _allThemes = [
    'friendship',
    'growth',
    'love',
    'betrayal',
    'redemption',
    'courage',
    'sacrifice',
    'discovery',
    'family',
    'justice',
  ];

  Widget _buildGenreSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Genre',
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
              _genres.map((genre) {
                final isSelected = _preferredGenre == genre['value'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _preferredGenre = genre['value'];
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
                              ? theme.primaryColor.withAlpha(26)
                              : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.primaryColor
                                : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          genre['icon'],
                          size: 4.w,
                          color:
                              isSelected
                                  ? theme.primaryColor
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          genre['label'],
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected
                                    ? theme.primaryColor
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

  Widget _buildLengthSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Story Length',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _lengths.map((length) {
                final isSelected = _storyLength == length['value'];
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
                    value: length['value'],
                    groupValue: _storyLength,
                    onChanged: (newValue) {
                      setState(() {
                        _storyLength = newValue!;
                      });
                      widget.onChanged();
                    },
                    title: Text(
                      length['label'],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color:
                            isSelected
                                ? theme.primaryColor
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      length['description'],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Themes (select multiple)',
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
              _allThemes.map((theme_name) {
                final isSelected = _favoriteThemes.contains(theme_name);
                return FilterChip(
                  selected: isSelected,
                  label: Text(
                    theme_name.substring(0, 1).toUpperCase() +
                        theme_name.substring(1),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _favoriteThemes.add(theme_name);
                      } else {
                        _favoriteThemes.remove(theme_name);
                      }
                    });
                    widget.onChanged();
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.primaryColor,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? theme.primaryColor : theme.dividerColor,
                  ),
                );
              }).toList(),
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
                  'AI Story Generation',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(Icons.auto_awesome, size: 5.w, color: theme.primaryColor),
              ],
            ),

            SizedBox(height: 3.h),

            // Genre Selection
            _buildGenreSelector(),

            SizedBox(height: 3.h),

            // Story Length
            _buildLengthSelector(),

            SizedBox(height: 3.h),

            // Writing Style
            Text(
              'Writing Style',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _writingStyle,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 2.h,
                ),
              ),
              items:
                  _styles.map((style) {
                    return DropdownMenuItem<String>(
                      value: style['value'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            style['label'],
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            style['description'],
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
                  _writingStyle = value!;
                });
                widget.onChanged();
              },
            ),

            SizedBox(height: 3.h),

            // Creativity Level
            Text(
              'Creativity Level: ${(_creativityLevel * 100).round()}%',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Slider(
              value: _creativityLevel,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _creativityLevel = value;
                });
                widget.onChanged();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conservative',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Very Creative',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Additional Options
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
                      Icon(Icons.forum_outlined, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Include Dialogue',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: _includeDialogue,
                        onChanged: (value) {
                          setState(() {
                            _includeDialogue = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  Row(
                    children: [
                      Icon(Icons.psychology_outlined, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Character Development',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: _includeCharacterDevelopment,
                        onChanged: (value) {
                          setState(() {
                            _includeCharacterDevelopment = value;
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

            // Theme Selection
            _buildThemeSelector(),
          ],
        ),
      ),
    );
  }
}
