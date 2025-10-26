import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class KeyboardPreferencesWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const KeyboardPreferencesWidget({super.key, required this.onChanged});

  @override
  State<KeyboardPreferencesWidget> createState() =>
      _KeyboardPreferencesWidgetState();
}

class _KeyboardPreferencesWidgetState extends State<KeyboardPreferencesWidget> {
  bool _autoCorrect = true;
  bool _spellCheck = true;
  bool _autoCapitalization = true;
  bool _smartPunctuation = true;
  String _keyboardType = 'default';
  String _textInputAction = 'newline';
  bool _hapticFeedback = false;
  String _fontSize = 'medium';
  String _fontFamily = 'inter';

  final List<Map<String, String>> _keyboardTypes = [
    {
      'value': 'default',
      'label': 'Default',
      'description': 'Standard keyboard',
    },
    {
      'value': 'text',
      'label': 'Text',
      'description': 'Optimized for text input',
    },
    {
      'value': 'multiline',
      'label': 'Multiline',
      'description': 'Best for long text',
    },
    {
      'value': 'emailAddress',
      'label': 'Email',
      'description': 'Email optimized',
    },
    {'value': 'url', 'label': 'URL', 'description': 'Web address input'},
  ];

  final List<Map<String, String>> _inputActions = [
    {
      'value': 'newline',
      'label': 'New Line',
      'description': 'Insert line break',
    },
    {'value': 'done', 'label': 'Done', 'description': 'Complete input'},
    {'value': 'next', 'label': 'Next', 'description': 'Move to next field'},
    {'value': 'send', 'label': 'Send', 'description': 'Send/submit text'},
  ];

  final List<Map<String, String>> _fontSizes = [
    {'value': 'small', 'label': 'Small', 'description': '12px'},
    {'value': 'medium', 'label': 'Medium', 'description': '16px'},
    {'value': 'large', 'label': 'Large', 'description': '20px'},
    {'value': 'xlarge', 'label': 'Extra Large', 'description': '24px'},
  ];

  final List<Map<String, String>> _fontFamilies = [
    {'value': 'inter', 'label': 'Inter', 'description': 'Clean and modern'},
    {'value': 'roboto', 'label': 'Roboto', 'description': 'Google font'},
    {
      'value': 'opensans',
      'label': 'Open Sans',
      'description': 'Highly readable',
    },
    {'value': 'lato', 'label': 'Lato', 'description': 'Professional'},
    {
      'value': 'playfair',
      'label': 'Playfair Display',
      'description': 'Elegant serif',
    },
  ];

  Widget _buildKeyboardTypeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keyboard Type',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        DropdownButtonFormField<String>(
          initialValue: _keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 2.h,
            ),
            prefixIcon: const Icon(Icons.keyboard),
          ),
          items:
              _keyboardTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        type['description']!,
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
              _keyboardType = value!;
            });
            widget.onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildInputActionSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Return Key Action',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        DropdownButtonFormField<String>(
          initialValue: _textInputAction,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 2.h,
            ),
            prefixIcon: const Icon(Icons.keyboard_return),
          ),
          items:
              _inputActions.map((action) {
                return DropdownMenuItem<String>(
                  value: action['value'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        action['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        action['description']!,
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
              _textInputAction = value!;
            });
            widget.onChanged();
          },
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
                  'Keyboard Preferences',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.keyboard_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Keyboard Type Selection
            _buildKeyboardTypeSelector(),

            SizedBox(height: 3.h),

            // Input Action Selection
            _buildInputActionSelector(),

            SizedBox(height: 3.h),

            // Text Input Features
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
                  Text(
                    'Text Input Features',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Auto Correct
                  Row(
                    children: [
                      Icon(Icons.auto_fix_high, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Correct',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Automatically fix spelling mistakes',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _autoCorrect,
                        onChanged: (value) {
                          setState(() {
                            _autoCorrect = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  // Spell Check
                  Row(
                    children: [
                      Icon(Icons.spellcheck, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spell Check',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Highlight misspelled words',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _spellCheck,
                        onChanged: (value) {
                          setState(() {
                            _spellCheck = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  // Auto Capitalization
                  Row(
                    children: [
                      Icon(Icons.format_color_text, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Capitalization',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Capitalize first letter of sentences',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _autoCapitalization,
                        onChanged: (value) {
                          setState(() {
                            _autoCapitalization = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  // Smart Punctuation
                  Row(
                    children: [
                      Icon(Icons.text_format, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Punctuation',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Convert quotes and dashes automatically',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _smartPunctuation,
                        onChanged: (value) {
                          setState(() {
                            _smartPunctuation = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  // Haptic Feedback
                  Row(
                    children: [
                      Icon(Icons.vibration, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haptic Feedback',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Vibrate on key presses',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _hapticFeedback,
                        onChanged: (value) {
                          setState(() {
                            _hapticFeedback = value;
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

            // Font Size Selection
            Text(
              'Text Size',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            SegmentedButton<String>(
              segments:
                  _fontSizes.map((size) {
                    return ButtonSegment(
                      value: size['value']!,
                      label: Text(size['label']!),
                      tooltip: size['description'],
                    );
                  }).toList(),
              selected: {_fontSize},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _fontSize = newSelection.first;
                });
                widget.onChanged();
              },
            ),

            SizedBox(height: 3.h),

            // Font Family Selection
            Text(
              'Text Font',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _fontFamily,
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
                  _fontFamilies.map((font) {
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
                  _fontFamily = value!;
                });
                widget.onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
