import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class JournalEntryCardWidget extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onTransform;
  final VoidCallback onDelete;

  const JournalEntryCardWidget({
    Key? key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onTransform,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(entry['created_at'] as String);
    final preview = entry['preview'] as String? ?? '';
    final mood = entry['mood'] as String? ?? 'neutral';
    final wordCount = entry['word_count'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Dismissible(
        key: Key(entry['id'].toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'delete',
            color: Colors.white,
            size: 6.w,
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context);
        },
        onDismissed: (direction) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Row(
                      children: [
                        _buildMoodIndicator(mood),
                        SizedBox(width: 2.w),
                        Text(
                          '$wordCount words',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  preview,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      'Edit',
                      'edit',
                      onEdit,
                    ),
                    SizedBox(width: 2.w),
                    _buildActionButton(
                      context,
                      'Transform',
                      'auto_awesome',
                      onTransform,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(String mood) {
    Color moodColor;
    String moodIcon;

    switch (mood.toLowerCase()) {
      case 'happy':
        moodColor = Colors.green;
        moodIcon = 'sentiment_very_satisfied';
        break;
      case 'sad':
        moodColor = Colors.blue;
        moodIcon = 'sentiment_very_dissatisfied';
        break;
      case 'excited':
        moodColor = Colors.orange;
        moodIcon = 'sentiment_satisfied';
        break;
      case 'calm':
        moodColor = Colors.teal;
        moodIcon = 'sentiment_neutral';
        break;
      case 'anxious':
        moodColor = Colors.red;
        moodIcon = 'sentiment_dissatisfied';
        break;
      default:
        moodColor = Colors.grey;
        moodIcon = 'sentiment_neutral';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: moodIcon,
            color: moodColor,
            size: 4.w,
          ),
          SizedBox(width: 1.w),
          Text(
            mood,
            style: TextStyle(
              color: moodColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text(
              'Are you sure you want to delete this journal entry? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              _buildContextMenuItem(context, 'Edit Entry', 'edit', onEdit),
              _buildContextMenuItem(
                  context, 'Transform to Story', 'auto_awesome', onTransform),
              _buildContextMenuItem(
                  context, 'Duplicate', 'content_copy', () {}),
              _buildContextMenuItem(
                  context, 'Add to Favorites', 'favorite_border', () {}),
              _buildContextMenuItem(context, 'Export', 'share', () {}),
              _buildContextMenuItem(
                context,
                'Delete',
                'delete',
                onDelete,
                isDestructive: true,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.lightTheme.colorScheme.onSurface,
        size: 6.w,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDestructive
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
