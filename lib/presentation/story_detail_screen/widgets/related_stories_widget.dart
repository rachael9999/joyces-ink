import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RelatedStoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> relatedStories;
  final Function(Map<String, dynamic>) onStoryTap;

  const RelatedStoriesWidget({
    Key? key,
    required this.relatedStories,
    required this.onStoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (relatedStories.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Stories',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: relatedStories.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final story = relatedStories[index];
                return _buildRelatedStoryCard(story);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedStoryCard(Map<String, dynamic> story) {
    return GestureDetector(
      onTap: () => onStoryTap(story),
      child: Container(
        width: 40.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Image
            Container(
              height: 12.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
              ),
              child: story['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CustomImageWidget(
                        imageUrl: story['imageUrl'] as String,
                        width: double.infinity,
                        height: 12.h,
                        fit: BoxFit.cover,
                        semanticLabel: story['semanticLabel'] as String? ??
                            'Story illustration',
                      ),
                    )
                  : Center(
                      child: CustomIconWidget(
                        iconName: 'auto_stories',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 32,
                      ),
                    ),
            ),
            // Story Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genre Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (story['genre'] as String? ?? 'Story').toUpperCase(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Story Title
                    Expanded(
                      child: Text(
                        story['title'] as String? ?? 'Untitled Story',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Story Stats
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${story['readingTime'] ?? 5}min',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                        if ((story['rating'] as int? ?? 0) > 0)
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'star',
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                                size: 12,
                              ),
                              SizedBox(width: 0.5.w),
                              Text(
                                '${story['rating']}',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
