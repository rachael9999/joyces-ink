import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StoryPreviewWidget extends StatefulWidget {
  final Map<String, dynamic> generatedStory;
  final VoidCallback onRegenerate;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onExport;

  const StoryPreviewWidget({
    Key? key,
    required this.generatedStory,
    required this.onRegenerate,
    required this.onEdit,
    required this.onSave,
    required this.onShare,
    required this.onExport,
  }) : super(key: key);

  @override
  State<StoryPreviewWidget> createState() => _StoryPreviewWidgetState();
}

class _StoryPreviewWidgetState extends State<StoryPreviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  bool _isFavorited = false;
  bool _isFullTextExpanded = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    // Start celebration animation
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  void _toggleTextExpansion() {
    setState(() {
      _isFullTextExpanded = !_isFullTextExpanded;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with celebration
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryLight,
                        AppTheme.primaryLight.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'celebration',
                        color: AppTheme.onPrimaryLight,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Story is Ready!',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.onPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Generated with advanced AI techniques',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.onPrimaryLight
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: AnimatedScale(
                          scale: _isFavorited ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: CustomIconWidget(
                            iconName:
                                _isFavorited ? 'favorite' : 'favorite_border',
                            color: _isFavorited
                                ? AppTheme.secondaryLight
                                : AppTheme.onPrimaryLight,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Story Content
                Container(
                  constraints: BoxConstraints(
                      maxHeight: _isFullTextExpanded ? 60.h : 40.h),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Story Title
                        Text(
                          widget.generatedStory['title'] as String? ??
                              'Untitled Story',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryLight,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Story Metadata
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children: [
                            _buildMetadataChip(
                              'genre',
                              widget.generatedStory['genre'] as String? ??
                                  'Unknown',
                            ),
                            _buildMetadataChip(
                              'schedule',
                              '${widget.generatedStory['wordCount'] ?? 0} words',
                            ),
                            _buildMetadataChip(
                              'access_time',
                              '${widget.generatedStory['readTime'] ?? 0} min read',
                            ),
                            _buildMetadataChip(
                              'visibility',
                              widget.generatedStory['options']
                                      ?['perspective'] ??
                                  'First Person',
                            ),
                            _buildMetadataChip(
                              'edit',
                              widget.generatedStory['options']
                                      ?['writingStyle'] ??
                                  'Descriptive',
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Story Quality Indicators
                        Row(
                          children: [
                            _buildQualityIndicator(
                              'Creativity',
                              (widget.generatedStory['options']?['creativity']
                                      as double?) ??
                                  0.7,
                              AppTheme.secondaryLight,
                            ),
                            SizedBox(width: 4.w),
                            _buildQualityIndicator(
                              'Pacing',
                              (widget.generatedStory['options']?['pacing']
                                      as double?) ??
                                  0.6,
                              AppTheme.primaryLight,
                            ),
                            SizedBox(width: 4.w),
                            _buildQualityIndicator(
                              'Character Dev.',
                              (widget.generatedStory['options']
                                      ?['characterDevelopment'] as double?) ??
                                  0.5,
                              Colors.orange,
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Story Content Preview
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.dividerLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Story Preview',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _toggleTextExpansion,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _isFullTextExpanded
                                                ? 'Collapse'
                                                : 'Expand',
                                            style: AppTheme
                                                .lightTheme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: AppTheme.primaryLight,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 1.w),
                                          CustomIconWidget(
                                            iconName: _isFullTextExpanded
                                                ? 'expand_less'
                                                : 'expand_more',
                                            color: AppTheme.primaryLight,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              MarkdownBody(
                                data: widget.generatedStory['content']
                                        as String? ??
                                    'No content available',
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: AppTheme.textPrimaryLight,
                                  ),
                                  h1: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryLight,
                                  ),
                                  strong: const TextStyle(fontWeight: FontWeight.w700),
                                  em: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      // Primary Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onSave,
                              icon: CustomIconWidget(
                                iconName: 'save',
                                color: AppTheme.onPrimaryLight,
                                size: 20,
                              ),
                              label: Text('Save Story'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryLight,
                                foregroundColor: AppTheme.onPrimaryLight,
                                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onRegenerate,
                              icon: CustomIconWidget(
                                iconName: 'refresh',
                                color: AppTheme.primaryLight,
                                size: 20,
                              ),
                              label: Text('Regenerate'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryLight,
                                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                                side: BorderSide(
                                    color: AppTheme.primaryLight, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Secondary Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: 'edit',
                            label: 'Edit',
                            onTap: widget.onEdit,
                            color: Colors.blue,
                          ),
                          _buildActionButton(
                            icon: 'share',
                            label: 'Share',
                            onTap: widget.onShare,
                            color: Colors.green,
                          ),
                          _buildActionButton(
                            icon: 'download',
                            label: 'Export',
                            onTap: widget.onExport,
                            color: Colors.orange,
                          ),
                          _buildActionButton(
                            icon: 'copy',
                            label: 'Copy',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: widget.generatedStory['content']
                                          as String? ??
                                      '',
                                ),
                              );
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Story copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQualityIndicator(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          LinearProgressIndicator(
            value: value,
            backgroundColor: AppTheme.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${(value * 100).toInt()}%',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip(String icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.primaryLight,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
