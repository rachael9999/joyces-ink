import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  const SearchBarWidget({
    Key? key,
    this.hintText = 'Search stories...',
    this.onChanged,
    this.onFilterTap,
    this.showFilter = true,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                  widget.onChanged?.call(value);
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _isSearching
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() {
                              _isSearching = false;
                            });
                            widget.onChanged?.call('');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (widget.showFilter) ...[
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'tune',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
