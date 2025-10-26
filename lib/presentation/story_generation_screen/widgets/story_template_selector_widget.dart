import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryTemplateSelectorWidget extends StatefulWidget {
  final String? selectedTemplate;
  final Function(String?) onTemplateSelected;

  const StoryTemplateSelectorWidget({
    Key? key,
    required this.selectedTemplate,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  State<StoryTemplateSelectorWidget> createState() =>
      _StoryTemplateSelectorWidgetState();
}

class _StoryTemplateSelectorWidgetState
    extends State<StoryTemplateSelectorWidget> {
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
    {
      'name': 'Slice of Life',
      'description': 'Realistic portrayal of everyday experiences',
      'icon': 'home',
      'structure': 'Daily Life → Small Events → Reflection → Insight',
      'bestFor': ['Literary Fiction', 'Contemporary', 'Memoir-style'],
    },
    {
      'name': 'Twist Narrative',
      'description': 'Misleading setup leading to surprise revelation',
      'icon': 'change_circle',
      'structure': 'Setup → Misdirection → Hints → Twist → New Understanding',
      'bestFor': ['Thriller', 'Mystery', 'Psychological'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_stories',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Story Templates',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            'Choose a narrative structure to guide your story generation',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),

          SizedBox(height: 2.h),

          // Template Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.85,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              return _buildTemplateCard(_templates[index]);
            },
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
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.1)
              : AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Icon and Name
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: template['icon'] as String,
                    color: isSelected
                        ? AppTheme.onPrimaryLight
                        : AppTheme.primaryLight,
                    size: 20,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    template['name'] as String,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryLight
                          : AppTheme.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              template['description'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 1.5.h),

            // Structure Overview
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.dividerLight.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                template['structure'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontSize: 10.sp,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          genre,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryLight,
                            fontSize: 9.sp,
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
}
