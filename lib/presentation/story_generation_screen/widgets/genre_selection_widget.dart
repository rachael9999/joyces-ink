import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GenreSelectionWidget extends StatefulWidget {
  final String? selectedGenre;
  final Function(String) onGenreSelected;

  const GenreSelectionWidget({
    Key? key,
    this.selectedGenre,
    required this.onGenreSelected,
  }) : super(key: key);

  @override
  State<GenreSelectionWidget> createState() => _GenreSelectionWidgetState();
}

class _GenreSelectionWidgetState extends State<GenreSelectionWidget> {
  final List<Map<String, dynamic>> genres = [
    {
      'name': 'Horror',
      'icon': 'nightlight_round',
      'color': const Color(0xFF8B0000),
      'description': 'Spine-chilling tales of terror',
    },
    {
      'name': 'Romance',
      'icon': 'favorite',
      'color': const Color(0xFFE91E63),
      'description': 'Heartwarming love stories',
    },
    {
      'name': 'Comedy',
      'icon': 'sentiment_very_satisfied',
      'color': const Color(0xFFFF9800),
      'description': 'Light-hearted and funny',
    },
    {
      'name': 'Mystery',
      'icon': 'search',
      'color': const Color(0xFF673AB7),
      'description': 'Intriguing puzzles to solve',
    },
    {
      'name': 'Drama',
      'icon': 'theater_comedy',
      'color': const Color(0xFF795548),
      'description': 'Emotional and compelling',
    },
    {
      'name': 'Chick-Flick',
      'icon': 'local_movies',
      'color': const Color(0xFFE1BEE7),
      'description': 'Feel-good stories',
    },
  ];

  void _selectGenre(String genre) {
    HapticFeedback.lightImpact();
    widget.onGenreSelected(genre);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Choose Your Genre',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        CarouselSlider.builder(
          itemCount: genres.length,
          itemBuilder: (context, index, realIndex) {
            final genre = genres[index];
            final isSelected = widget.selectedGenre == genre['name'];

            return GestureDetector(
              onTap: () => _selectGenre(genre['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (genre['color'] as Color).withValues(alpha: 0.1)
                      : AppTheme.lightTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? genre['color'] as Color
                        : AppTheme.dividerLight,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? (genre['color'] as Color).withValues(alpha: 0.3)
                          : AppTheme.shadowLight,
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: (genre['color'] as Color).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: genre['icon'] as String,
                        color: genre['color'] as Color,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      genre['name'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? genre['color'] as Color
                            : AppTheme.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      genre['description'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 25.h,
            viewportFraction: 0.7,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}
