import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class WritingPromptsSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const WritingPromptsSectionWidget({super.key, required this.onChanged});

  @override
  State<WritingPromptsSectionWidget> createState() =>
      _WritingPromptsSectionWidgetState();
}

class _WritingPromptsSectionWidgetState
    extends State<WritingPromptsSectionWidget> {
  bool _enablePrompts = true;
  String _promptFrequency = 'daily';
  List<String> _selectedCategories = ['creative', 'personal'];
  String _promptComplexity = 'medium';
  bool _customPromptsEnabled = false;

  final List<String> _categories = [
    'creative',
    'personal',
    'professional',
    'philosophical',
    'adventure',
    'relationships',
    'memories',
    'dreams',
  ];

  final List<Map<String, String>> _samplePrompts = [
    {
      'category': 'creative',
      'prompt': 'Write about a world where colors have personalities...',
    },
    {
      'category': 'personal',
      'prompt': 'Describe a moment that changed your perspective on life.',
    },
    {
      'category': 'adventure',
      'prompt': 'You found a mysterious key. What does it unlock?',
    },
  ];

  Widget _buildFrequencySelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prompt Frequency',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'daily',
                groupValue: _promptFrequency,
                onChanged: (value) {
                  setState(() {
                    _promptFrequency = value!;
                  });
                  widget.onChanged();
                },
                title: Row(
                  children: [
                    Icon(Icons.today, size: 4.w),
                    SizedBox(width: 2.w),
                    Text('Daily', style: GoogleFonts.inter(fontSize: 14.sp)),
                  ],
                ),
                subtitle: Text(
                  'New prompt every day',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Divider(height: 0.5.h),
              RadioListTile<String>(
                value: 'weekly',
                groupValue: _promptFrequency,
                onChanged: (value) {
                  setState(() {
                    _promptFrequency = value!;
                  });
                  widget.onChanged();
                },
                title: Row(
                  children: [
                    Icon(Icons.calendar_view_week, size: 4.w),
                    SizedBox(width: 2.w),
                    Text('Weekly', style: GoogleFonts.inter(fontSize: 14.sp)),
                  ],
                ),
                subtitle: Text(
                  'New prompt every week',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Divider(height: 0.5.h),
              RadioListTile<String>(
                value: 'custom',
                groupValue: _promptFrequency,
                onChanged: (value) {
                  setState(() {
                    _promptFrequency = value!;
                  });
                  widget.onChanged();
                },
                title: Row(
                  children: [
                    Icon(Icons.tune, size: 4.w),
                    SizedBox(width: 2.w),
                    Text(
                      'On Demand',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Get prompts when you ask',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Categories',
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
              _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  selected: isSelected,
                  label: Text(
                    category.substring(0, 1).toUpperCase() +
                        category.substring(1),
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
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
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

  Widget _buildSamplePrompts() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Prompts',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _samplePrompts.map((prompt) {
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withAlpha(13),
                        theme.primaryColor.withAlpha(26),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withAlpha(51)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              prompt['category']!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.lightbulb_outline,
                            size: 4.w,
                            color: theme.primaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        prompt['prompt']!,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
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
                  'Writing Prompts',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.lightbulb_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Enable/Disable Prompts
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _enablePrompts ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: _enablePrompts ? Colors.amber : Colors.grey,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Writing Prompts',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _enablePrompts
                              ? 'Get daily inspiration for your writing'
                              : 'Prompts are disabled',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enablePrompts,
                    onChanged: (value) {
                      setState(() {
                        _enablePrompts = value;
                      });
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ),

            if (_enablePrompts) ...[
              SizedBox(height: 3.h),

              // Frequency Selection
              _buildFrequencySelector(),

              SizedBox(height: 3.h),

              // Complexity Selector
              Text(
                'Prompt Complexity',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'simple',
                    label: Text('Simple'),
                    icon: Icon(Icons.star_border),
                  ),
                  ButtonSegment(
                    value: 'medium',
                    label: Text('Medium'),
                    icon: Icon(Icons.star_half),
                  ),
                  ButtonSegment(
                    value: 'complex',
                    label: Text('Complex'),
                    icon: Icon(Icons.star),
                  ),
                ],
                selected: {_promptComplexity},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _promptComplexity = newSelection.first;
                  });
                  widget.onChanged();
                },
              ),

              SizedBox(height: 3.h),

              // Category Selection
              _buildCategorySelector(),

              SizedBox(height: 3.h),

              // Custom Prompts Toggle
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_note, size: 4.w),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Prompts',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Create and use your own writing prompts',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _customPromptsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _customPromptsEnabled = value;
                        });
                        widget.onChanged();
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Sample Prompts
              _buildSamplePrompts(),
            ],
          ],
        ),
      ),
    );
  }
}
