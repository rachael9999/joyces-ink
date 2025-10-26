import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class StoryContentWidget extends StatefulWidget {
  final String content;
  final bool isEditing;
  final Function(String) onContentChanged;
  final double readingProgress;

  const StoryContentWidget({
    Key? key,
    required this.content,
    required this.isEditing,
    required this.onContentChanged,
    required this.readingProgress,
  }) : super(key: key);

  @override
  State<StoryContentWidget> createState() => _StoryContentWidgetState();
}

class _StoryContentWidgetState extends State<StoryContentWidget> {
  final ScrollController _scrollController = ScrollController();
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateReadingProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateReadingProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateReadingProgress() {
    // Reading progress calculation would be handled by parent
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            // Reading Progress Indicator
            if (!widget.isEditing && widget.readingProgress > 0)
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reading Progress',
                          style: AppTheme.lightTheme.textTheme.labelSmall,
                        ),
                        Text(
                          '${(widget.readingProgress * 100).toInt()}%',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    LinearProgressIndicator(
                      value: widget.readingProgress,
                      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            // Story Content
            Expanded(
              child: widget.isEditing
                  ? _buildEditingContent()
                  : _buildReadingContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingContent() {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _textScale = (_textScale * details.scale).clamp(0.8, 2.0);
        });
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            widget.content,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontSize:
                  (AppTheme.lightTheme.textTheme.bodyLarge?.fontSize ?? 16) *
                      _textScale,
              height: 1.6,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }

  Widget _buildEditingContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextFormField(
        initialValue: widget.content,
        onChanged: widget.onContentChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
          hintText: 'Start writing your story...',
          hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
