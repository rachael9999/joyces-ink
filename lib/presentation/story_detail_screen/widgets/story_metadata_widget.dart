import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryMetadataWidget extends StatelessWidget {
  final String genre;
  final DateTime creationDate;
  final int wordCount;
  final int readingTimeMinutes;

  const StoryMetadataWidget({
    Key? key,
    required this.genre,
    required this.creationDate,
    required this.wordCount,
    required this.readingTimeMinutes,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              genre.toUpperCase(),
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Metadata Row
          Row(
            children: [
              Expanded(
                child: _buildMetadataItem(
                  icon: 'calendar_today',
                  label: 'Created',
                  value: _formatDate(creationDate),
                ),
              ),
              Expanded(
                child: _buildMetadataItem(
                  icon: 'text_fields',
                  label: 'Words',
                  value: wordCount.toString(),
                ),
              ),
              Expanded(
                child: _buildMetadataItem(
                  icon: 'schedule',
                  label: 'Read Time',
                  value: '${readingTimeMinutes}min',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
