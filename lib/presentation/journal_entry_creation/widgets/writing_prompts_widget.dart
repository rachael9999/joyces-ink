import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class WritingPromptsWidget extends StatefulWidget {
  final Function(String) onPromptSelected;

  const WritingPromptsWidget({
    Key? key,
    required this.onPromptSelected,
  }) : super(key: key);

  @override
  State<WritingPromptsWidget> createState() => _WritingPromptsWidgetState();
}

class _WritingPromptsWidgetState extends State<WritingPromptsWidget> {
  final List<Map<String, dynamic>> _prompts = [
    {
      'category': 'Reflection',
      'prompts': [
        'What made you smile today?',
        'Describe a moment when you felt truly grateful.',
        'What challenge did you overcome recently?',
        'Write about someone who inspired you this week.',
        'What lesson did you learn today?',
      ],
    },
    {
      'category': 'Creativity',
      'prompts': [
        'If you could have dinner with anyone, who would it be and why?',
        'Describe your perfect day from start to finish.',
        'What would you do if you had unlimited resources?',
        'Write about a place you\'ve never been but dream of visiting.',
        'If you could master any skill instantly, what would it be?',
      ],
    },
    {
      'category': 'Memories',
      'prompts': [
        'Write about your favorite childhood memory.',
        'Describe a tradition that\'s important to your family.',
        'What\'s the best advice you\'ve ever received?',
        'Write about a time when you helped someone.',
        'Describe a moment that changed your perspective.',
      ],
    },
    {
      'category': 'Future',
      'prompts': [
        'Where do you see yourself in five years?',
        'What goals are you working towards right now?',
        'Write a letter to your future self.',
        'What legacy do you want to leave behind?',
        'Describe your ideal life in detail.',
      ],
    },
    {
      'category': 'Emotions',
      'prompts': [
        'Write about a time when you felt proud of yourself.',
        'Describe what happiness means to you.',
        'What are you most excited about right now?',
        'Write about overcoming a fear.',
        'What makes you feel most alive?',
      ],
    },
  ];

  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 1.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Writing Prompts',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Category Tabs
          Container(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: _prompts.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6.w),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _prompts[index]['category'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Prompts List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount:
                  (_prompts[_selectedCategoryIndex]['prompts'] as List).length,
              itemBuilder: (context, index) {
                final prompt = (_prompts[_selectedCategoryIndex]['prompts']
                    as List)[index] as String;
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: GestureDetector(
                    onTap: () {
                      widget.onPromptSelected(prompt);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt,
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          CustomIconWidget(
                            iconName: 'arrow_forward_ios',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 4.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
