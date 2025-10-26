import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedOptionsWidget extends StatefulWidget {
  final Map<String, dynamic> options;
  final Function(Map<String, dynamic>) onOptionsChanged;
  final String? selectedTemplate;
  final Function(String?) onTemplateSelected;

  const AdvancedOptionsWidget({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    this.selectedTemplate,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  State<AdvancedOptionsWidget> createState() => _AdvancedOptionsWidgetState();
}

class _AdvancedOptionsWidgetState extends State<AdvancedOptionsWidget> {
  bool _isExpanded = false;

  // Story templates data
  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'The Hero\'s Journey',
      'description':
          'Classic adventure structure with challenges and transformation',
      'icon': 'shield',
      'structure': 'Ordinary World → Call to Adventure → Trials → Return',
      'bestFor': ['Adventure', 'Fantasy', 'Drama'],
    },
    {
      'name': 'Three-Act Structure',
      'description': 'Traditional beginning, middle, and end format',
      'icon': 'movie',
      'structure': 'Setup → Confrontation → Resolution',
      'bestFor': ['Drama', 'Romance', 'Comedy'],
    },
    {
      'name': 'Mystery Framework',
      'description': 'Clues, investigation, and revelation structure',
      'icon': 'search',
      'structure': 'Incident → Investigation → Clues → Resolution',
      'bestFor': ['Mystery', 'Thriller', 'Crime'],
    },
    {
      'name': 'Character Study',
      'description': 'Focus on internal conflict and character development',
      'icon': 'psychology',
      'structure': 'Introduction → Internal Conflict → Growth → Realization',
      'bestFor': ['Literary Fiction', 'Drama', 'Coming-of-Age'],
    },
    {
      'name': 'Romance Arc',
      'description': 'Meet-cute to happily ever after structure',
      'icon': 'favorite',
      'structure': 'Meeting → Attraction → Conflict → Resolution → Union',
      'bestFor': ['Romance', 'Romantic Comedy', 'Chick-Flick'],
    },
    {
      'name': 'Horror Build-up',
      'description': 'Gradual tension building to climactic terror',
      'icon': 'warning',
      'structure': 'Normalcy → First Signs → Escalation → Terror → Aftermath',
      'bestFor': ['Horror', 'Thriller', 'Supernatural'],
    },
  ];

  void _updateOption(String key, dynamic value) {
    final updatedOptions = Map<String, dynamic>.from(widget.options);
    updatedOptions[key] = value;
    widget.onOptionsChanged(updatedOptions);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.primaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Advanced Options',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.textSecondaryLight,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: AppTheme.dividerLight),
                        SizedBox(height: 3.h),

                        // Story Templates Section
                        _buildSectionHeader('Story Templates', 'auto_stories'),
                        SizedBox(height: 1.h),
                        Text(
                          'Choose a narrative structure to guide your story generation',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Template Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _templates.length,
                          itemBuilder: (context, index) {
                            return _buildTemplateCard(_templates[index]);
                          },
                        ),

                        SizedBox(height: 4.h),

                        // Story Length
                        _buildSectionHeader('Story Length', 'schedule'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children:
                              ['Short', 'Medium', 'Long', 'Epic'].map((length) {
                            final isSelected =
                                widget.options['length'] == length;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _updateOption('length', length),
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: length != 'Epic' ? 1.5.w : 0),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 1.8.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryLight
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryLight
                                          : AppTheme.dividerLight,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        length,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: isSelected
                                              ? AppTheme.onPrimaryLight
                                              : AppTheme.textPrimaryLight,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        _getLengthSubtitle(length),
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: isSelected
                                              ? AppTheme.onPrimaryLight
                                                  .withValues(alpha: 0.8)
                                              : AppTheme.textSecondaryLight,
                                          fontSize: 10.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 4.h),

                        // Narrative Perspective
                        _buildSectionHeader(
                            'Narrative Perspective', 'visibility'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPerspectiveOption(
                                'First Person',
                                'I walked through...',
                                'First Person',
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: _buildPerspectiveOption(
                                'Third Person',
                                'They walked through...',
                                'Third Person',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // Writing Style
                        _buildSectionHeader('Writing Style', 'edit'),
                        SizedBox(height: 1.5.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children: [
                            'Descriptive',
                            'Dialogue-Heavy',
                            'Action-Packed',
                            'Introspective',
                            'Poetic'
                          ].map((style) {
                            final isSelected =
                                widget.options['writingStyle'] == style;
                            return GestureDetector(
                              onTap: () => _updateOption('writingStyle', style),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.2.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.secondaryLight
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.secondaryLight
                                        : AppTheme.dividerLight,
                                  ),
                                ),
                                child: Text(
                                  style,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 4.h),

                        // Character Development
                        _buildSectionHeader('Character Development', 'person'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Text(
                              'Light',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.primaryLight,
                                  inactiveTrackColor: AppTheme.dividerLight,
                                  thumbColor: AppTheme.primaryLight,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: (widget.options['characterDevelopment']
                                          as double?) ??
                                      0.5,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 4,
                                  onChanged: (value) => _updateOption(
                                      'characterDevelopment', value),
                                ),
                              ),
                            ),
                            Text(
                              'Deep',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Pacing
                        _buildSectionHeader('Story Pacing', 'speed'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Text(
                              'Slow',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.secondaryLight,
                                  inactiveTrackColor: AppTheme.dividerLight,
                                  thumbColor: AppTheme.secondaryLight,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                ),
                                child: Slider(
                                  value:
                                      (widget.options['pacing'] as double?) ??
                                          0.6,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 4,
                                  onChanged: (value) =>
                                      _updateOption('pacing', value),
                                ),
                              ),
                            ),
                            Text(
                              'Fast',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Tone Intensity
                        _buildSectionHeader('Tone Intensity', 'mood'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Text(
                              'Light',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.primaryLight,
                                  inactiveTrackColor: AppTheme.dividerLight,
                                  thumbColor: AppTheme.primaryLight,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: (widget.options['toneIntensity']
                                          as double?) ??
                                      0.5,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 4,
                                  onChanged: (value) =>
                                      _updateOption('toneIntensity', value),
                                ),
                              ),
                            ),
                            Text(
                              'Intense',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Creativity Level
                        _buildSectionHeader('Creativity Level', 'auto_awesome'),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Text(
                              'Realistic',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.secondaryLight,
                                  inactiveTrackColor: AppTheme.dividerLight,
                                  thumbColor: AppTheme.secondaryLight,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: (widget.options['creativity']
                                          as double?) ??
                                      0.7,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 4,
                                  onChanged: (value) =>
                                      _updateOption('creativity', value),
                                ),
                              ),
                            ),
                            Text(
                              'Fantasy',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // Target Audience
                        _buildSectionHeader('Target Audience', 'group'),
                        SizedBox(height: 1.5.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children: [
                            'All Ages',
                            'Young Adult',
                            'Adult',
                            'Mature'
                          ].map((audience) {
                            final isSelected =
                                widget.options['targetAudience'] == audience;
                            return GestureDetector(
                              onTap: () =>
                                  _updateOption('targetAudience', audience),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.2.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryLight
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryLight
                                        : AppTheme.dividerLight,
                                  ),
                                ),
                                child: Text(
                                  audience,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: isSelected
                                        ? AppTheme.onPrimaryLight
                                        : AppTheme.textPrimaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 4.h),

                        // Ending Style
                        _buildSectionHeader('Ending Style', 'flag'),
                        SizedBox(height: 1.5.h),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEndingOption('Open Ending',
                                      'Leaves room for interpretation'),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: _buildEndingOption(
                                      'Conclusive', 'Wraps up all storylines'),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEndingOption('Cliffhanger',
                                      'Sets up for continuation'),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: _buildEndingOption(
                                      'Twist Ending', 'Surprising revelation'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final isSelected = widget.selectedTemplate == template['name'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTemplateSelected(
          isSelected ? null : template['name'] as String,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.1)
              : AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Template Icon and Name
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: template['icon'] as String,
                    color: isSelected
                        ? AppTheme.onPrimaryLight
                        : AppTheme.primaryLight,
                    size: 16,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    template['name'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryLight
                          : AppTheme.textPrimaryLight,
                      fontSize: 11.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // Description
            Text(
              template['description'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                height: 1.3,
                fontSize: 10.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Best For Tags
            Wrap(
              spacing: 1.w,
              runSpacing: 0.5.h,
              children: (template['bestFor'] as List<String>)
                  .take(2)
                  .map((genre) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w,
                          vertical: 0.3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          genre,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryLight,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.primaryLight,
          size: 18,
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildPerspectiveOption(String title, String example, String value) {
    final isSelected = widget.options['perspective'] == value;
    return GestureDetector(
      onTap: () => _updateOption('perspective', value),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? AppTheme.onPrimaryLight
                    : AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              example,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppTheme.onPrimaryLight.withValues(alpha: 0.8)
                    : AppTheme.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndingOption(String title, String description) {
    final isSelected = widget.options['endingStyle'] == title;
    return GestureDetector(
      onTap: () => _updateOption('endingStyle', title),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryLight : AppTheme.dividerLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.textSecondaryLight,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLengthSubtitle(String length) {
    switch (length) {
      case 'Short':
        return '500-800 words';
      case 'Medium':
        return '800-1500 words';
      case 'Long':
        return '1500-3000 words';
      case 'Epic':
        return '3000+ words';
      default:
        return '';
    }
  }
}
