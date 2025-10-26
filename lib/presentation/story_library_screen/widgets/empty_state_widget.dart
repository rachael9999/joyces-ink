import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String genre;
  final VoidCallback? onCreateStory;

  const EmptyStateWidget({
    Key? key,
    required this.genre,
    this.onCreateStory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(),
            SizedBox(height: 4.h),
            _buildTitle(),
            SizedBox(height: 2.h),
            _buildDescription(),
            SizedBox(height: 4.h),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: _getGenreColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: _getGenreIcon(),
          color: _getGenreColor(),
          size: 60,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _getEmptyTitle(),
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      _getEmptyDescription(),
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      onPressed: onCreateStory,
      icon: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 20,
      ),
      label: Text('Create Your First Story'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  String _getEmptyTitle() {
    switch (genre.toLowerCase()) {
      case 'horror':
        return 'No Spine-Chilling Tales Yet';
      case 'romance':
        return 'No Love Stories Yet';
      case 'comedy':
        return 'No Funny Stories Yet';
      case 'mystery':
        return 'No Mysteries to Solve';
      case 'drama':
        return 'No Dramatic Tales Yet';
      case 'chick-flick':
        return 'No Feel-Good Stories Yet';
      case 'favorites':
        return 'No Favorite Stories Yet';
      default:
        return 'No Stories Yet';
    }
  }

  String _getEmptyDescription() {
    switch (genre.toLowerCase()) {
      case 'horror':
        return 'Transform your darkest thoughts and experiences into thrilling horror stories that will keep readers on the edge of their seats.';
      case 'romance':
        return 'Turn your romantic moments and heartfelt experiences into beautiful love stories that touch the soul.';
      case 'comedy':
        return 'Convert your funny experiences and humorous observations into delightful comedy stories that bring joy and laughter.';
      case 'mystery':
        return 'Transform your curious thoughts and puzzling experiences into intriguing mystery stories full of suspense.';
      case 'drama':
        return 'Turn your emotional experiences and life lessons into powerful dramatic stories that resonate deeply.';
      case 'chick-flick':
        return 'Convert your uplifting moments and personal growth into feel-good stories that inspire and entertain.';
      case 'favorites':
        return 'Mark stories as favorites by tapping the heart icon. Your most beloved tales will appear here for easy access.';
      default:
        return 'Start your creative journey by writing in your journal. Transform your thoughts and experiences into captivating stories across different genres.';
    }
  }

  String _getGenreIcon() {
    switch (genre.toLowerCase()) {
      case 'horror':
        return 'psychology';
      case 'romance':
        return 'favorite';
      case 'comedy':
        return 'sentiment_very_satisfied';
      case 'mystery':
        return 'search';
      case 'drama':
        return 'theater_comedy';
      case 'chick-flick':
        return 'auto_awesome';
      case 'favorites':
        return 'favorite_border';
      default:
        return 'auto_stories';
    }
  }

  Color _getGenreColor() {
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
      case 'favorites':
        return Colors.amber;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
