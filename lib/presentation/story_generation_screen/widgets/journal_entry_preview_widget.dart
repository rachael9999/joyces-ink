import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class JournalEntryPreviewWidget extends StatefulWidget {
  final Map<String, dynamic> journalEntry;
  final VoidCallback onEdit;

  const JournalEntryPreviewWidget({
    Key? key,
    required this.journalEntry,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<JournalEntryPreviewWidget> createState() =>
      _JournalEntryPreviewWidgetState();
}

class _JournalEntryPreviewWidgetState extends State<JournalEntryPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Stack(
                children: [
                  // Background gradient container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE8F4FD),
                          const Color(0xFFF8FBFF),
                          const Color(0xFFEEF7FF),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryLight.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.7),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with floating effect
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Row(
                            children: [
                              // Dreamy icon
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryLight
                                          .withValues(alpha: 0.2),
                                      Colors.purple.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryLight
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CustomIconWidget(
                                  iconName: 'auto_stories',
                                  color: AppTheme.primaryLight,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Journal Entry',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.primaryLight
                                            .withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      widget.journalEntry['title'] as String? ??
                                          'Untitled Entry',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2D3748),
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Content with dreamy styling
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppTheme.primaryLight.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.journalEntry['content'] as String? ??
                                'No content available',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              height: 1.6,
                              color: const Color(0xFF4A5568),
                              fontSize: 14.sp,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Bottom info with dreamy tags
                        Row(
                          children: [
                            // Date and mood info
                            Expanded(
                              child: Wrap(
                                spacing: 3.w,
                                runSpacing: 1.h,
                                children: [
                                  _buildInfoChip(
                                    icon: 'calendar_today',
                                    text: widget.journalEntry['date']
                                            as String? ??
                                        'No date',
                                    color: Colors.blue,
                                  ),
                                  if (widget.journalEntry['mood'] != null)
                                    _buildInfoChip(
                                      icon: 'mood',
                                      text:
                                          widget.journalEntry['mood'] as String,
                                      color: Colors.purple,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Floating edit button
                  Positioned(
                    top: 2.h,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: widget.onEdit,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryLight,
                              AppTheme.primaryLight.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryLight.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CustomIconWidget(
                          iconName: 'edit',
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Floating decorative elements
                  Positioned(
                    top: -10,
                    left: 10.w,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    right: 15.w,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color.withValues(alpha: 0.8),
            size: 14,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
