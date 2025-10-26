import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> story;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onFavorite;
  final VoidCallback? onExport;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onChangeGenre;
  final VoidCallback? onViewOriginal;
  final bool isGridView;

  const StoryCardWidget({
    Key? key,
    required this.story,
    this.onTap,
    this.onShare,
    this.onEdit,
    this.onFavorite,
    this.onExport,
    this.onDelete,
    this.onDuplicate,
    this.onChangeGenre,
    this.onViewOriginal,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(story['id']),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onShare?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
            foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
            icon: Icons.share,
            label: 'Share',
          ),
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onFavorite?.call(),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            icon: (story['isFavorite'] as bool? ?? false)
                ? Icons.favorite
                : Icons.favorite_border,
            label: 'Favorite',
          ),
          SlidableAction(
            onPressed: (_) => onExport?.call(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.download,
            label: 'Export',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(
            horizontal: isGridView ? 1.w : 4.w,
            vertical: 1.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: isGridView ? _buildGridCard() : _buildListCard(),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverImage(),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: 1.h),
                _buildGenreBadge(),
                SizedBox(height: 1.h),
                _buildMetadata(),
                SizedBox(height: 1.h),
                _buildRating(),
              ],
            ),
          ),
          _buildFavoriteIcon(),
        ],
      ),
    );
  }

  Widget _buildGridCard() {
    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                _buildCoverImage(isGrid: true),
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: _buildFavoriteIcon(),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(maxLines: 2),
                SizedBox(height: 0.5.h),
                _buildGenreBadge(),
                const Spacer(),
                _buildRating(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage({bool isGrid = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CustomImageWidget(
        imageUrl: story['coverImage'] as String? ?? '',
        width: isGrid ? double.infinity : 20.w,
        height: isGrid ? double.infinity : 12.h,
        fit: BoxFit.cover,
        semanticLabel:
            story['coverImageSemanticLabel'] as String? ?? 'Story cover image',
      ),
    );
  }

  Widget _buildTitle({int maxLines = 2}) {
    return Text(
      story['title'] as String? ?? 'Untitled Story',
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildGenreBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _getGenreColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getGenreColor(),
          width: 1,
        ),
      ),
      child: Text(
        story['genre'] as String? ?? 'Unknown',
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: _getGenreColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    final createdDate = story['createdDate'] as DateTime?;
    final wordCount = story['wordCount'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          createdDate != null
              ? '${createdDate.month}/${createdDate.day}/${createdDate.year}'
              : 'Unknown date',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          '$wordCount words',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    final rating = story['rating'] as double? ?? 0.0;

    return Row(
      children: [
        ...List.generate(5, (index) {
          return CustomIconWidget(
            iconName: index < rating.floor() ? 'star' : 'star_border',
            color: Colors.amber,
            size: 16,
          );
        }),
        SizedBox(width: 1.w),
        Text(
          rating.toStringAsFixed(1),
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteIcon() {
    final isFavorite = story['isFavorite'] as bool? ?? false;

    return GestureDetector(
      onTap: onFavorite,
      child: Container(
        padding: EdgeInsets.all(1.w),
        child: CustomIconWidget(
          iconName: isFavorite ? 'favorite' : 'favorite_border',
          color: isFavorite
              ? Colors.red
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Color _getGenreColor() {
    final genre = story['genre'] as String? ?? '';
    switch (genre.toLowerCase()) {
      case 'horror':
        return Colors.red;
      case 'romance':
        return Colors.pink;
      case 'comedy':
        return Colors.orange;
      case 'mystery':
        return Colors.purple;
      case 'drama':
        return Colors.blue;
      case 'chick-flick':
        return Colors.teal;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(
              icon: 'content_copy',
              title: 'Duplicate Story',
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'category',
              title: 'Change Genre',
              onTap: () {
                Navigator.pop(context);
                onChangeGenre?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'book',
              title: 'View Original Journal',
              onTap: () {
                Navigator.pop(context);
                onViewOriginal?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }
}
