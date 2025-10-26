import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MoodSelectorWidget extends StatefulWidget {
  final Function(String) onMoodSelected;
  final String? selectedMood;

  const MoodSelectorWidget({
    Key? key,
    required this.onMoodSelected,
    this.selectedMood,
  }) : super(key: key);

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget> {
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'value': 'happy', 'color': Color(0xFF4CAF50)},
    {'emoji': '😎', 'label': 'Confident', 'value': 'confident', 'color': Color(0xFF3F51B5)},
    {'emoji': '😢', 'label': 'Sad', 'value': 'sad', 'color': Color(0xFF2196F3)},
    {'emoji': '😡', 'label': 'Angry', 'value': 'angry', 'color': Color(0xFFF44336)},
    {'emoji': '😴', 'label': 'Tired', 'value': 'tired', 'color': Color(0xFF9C27B0)},
    {'emoji': '😍', 'label': 'Loved', 'value': 'loved', 'color': Color(0xFFE91E63)},
    {'emoji': '😰', 'label': 'Anxious', 'value': 'anxious', 'color': Color(0xFFFF9800)},
    {'emoji': '🤔', 'label': 'Thoughtful', 'value': 'thoughtful', 'color': Color(0xFF607D8B)},
    {'emoji': '🥳', 'label': 'Excited', 'value': 'excited', 'color': Color(0xFFFFEB3B)},
    {'emoji': '😌', 'label': 'Peaceful', 'value': 'peaceful', 'color': Color(0xFF009688)},
];

  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.selectedMood;
  }

  void _selectMood(Map<String, dynamic> mood) {
    setState(() {
      _selectedMood = mood['value'] as String;
    });
    widget.onMoodSelected(mood['value'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'How are you feeling?',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 12.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = _selectedMood == mood['value'];

                return GestureDetector(
                  onTap: () => _selectMood(mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (mood['color'] as Color).withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                        color: isSelected
                            ? (mood['color'] as Color)
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (mood['color'] as Color)
                                    .withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood['emoji'] as String,
                          style: TextStyle(fontSize: 8.w),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          mood['label'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? (mood['color'] as Color)
                                : AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
