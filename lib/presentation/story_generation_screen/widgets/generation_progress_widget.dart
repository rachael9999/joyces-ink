import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GenerationProgressWidget extends StatefulWidget {
  final String selectedGenre;
  final double progress;
  final String currentStep;
  final int estimatedTimeRemaining;

  const GenerationProgressWidget({
    Key? key,
    required this.selectedGenre,
    required this.progress,
    required this.currentStep,
    required this.estimatedTimeRemaining,
  }) : super(key: key);

  @override
  State<GenerationProgressWidget> createState() =>
      _GenerationProgressWidgetState();
}

class _GenerationProgressWidgetState extends State<GenerationProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Color _getGenreColor() {
    switch (widget.selectedGenre.toLowerCase()) {
      case 'horror':
        return const Color(0xFF8B0000);
      case 'romance':
        return const Color(0xFFE91E63);
      case 'comedy':
        return const Color(0xFFFF9800);
      case 'mystery':
        return const Color(0xFF673AB7);
      case 'drama':
        return const Color(0xFF795548);
      case 'chick-flick':
        return const Color(0xFFE1BEE7);
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getGenreIcon() {
    switch (widget.selectedGenre.toLowerCase()) {
      case 'horror':
        return 'nightlight_round';
      case 'romance':
        return 'favorite';
      case 'comedy':
        return 'sentiment_very_satisfied';
      case 'mystery':
        return 'search';
      case 'drama':
        return 'theater_comedy';
      case 'chick-flick':
        return 'local_movies';
      default:
        return 'auto_awesome';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreColor = _getGenreColor();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: genreColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Genre Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * 3.14159,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: genreColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: genreColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: _getGenreIcon(),
                          color: genreColor,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Progress Title
          Text(
            'Crafting Your ${widget.selectedGenre} Story',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: genreColor,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Current Step
          Text(
            widget.currentStep,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: genreColor,
                    ),
                  ),
                  Text(
                    '${widget.estimatedTimeRemaining}s remaining',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.dividerLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          genreColor,
                          genreColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Fun Facts or Tips
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: genreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: genreColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: genreColor,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _getGenreTip(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGenreTip() {
    switch (widget.selectedGenre.toLowerCase()) {
      case 'horror':
        return 'Did you know? The best horror stories often start with ordinary situations that slowly become extraordinary.';
      case 'romance':
        return 'Fun fact: Romance stories are most engaging when characters have genuine chemistry and shared values.';
      case 'comedy':
        return 'Tip: Great comedy comes from unexpected situations and relatable character flaws.';
      case 'mystery':
        return 'Mystery tip: The best mysteries plant clues early that readers can discover alongside the protagonist.';
      case 'drama':
        return 'Drama insight: Compelling drama focuses on characters making difficult choices under pressure.';
      case 'chick-flick':
        return 'Feel-good fact: The best feel-good stories celebrate personal growth and meaningful relationships.';
      default:
        return 'Creating stories is an art that combines imagination with the human experience.';
    }
  }
}
