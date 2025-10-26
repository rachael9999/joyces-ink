import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TextEditorWidget extends StatefulWidget {
  final Function(String) onTextChanged;
  final String initialText;

  const TextEditorWidget({
    Key? key,
    required this.onTextChanged,
    this.initialText = '',
  }) : super(key: key);

  @override
  State<TextEditorWidget> createState() => _TextEditorWidgetState();
}

class _TextEditorWidgetState extends State<TextEditorWidget> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    if (widget.initialText.isNotEmpty) {
      _controller.document = Document()..insert(0, widget.initialText);
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final text = _controller.document.toPlainText();
    widget.onTextChanged(text);
  }

  void _onFocusChanged() {
    setState(() {
      _showToolbar = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text Editor
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: QuillEditor.basic(
              controller: _controller,
              focusNode: _focusNode,
              config: QuillEditorConfig(
                placeholder: 'Start writing your thoughts...',
                padding: EdgeInsets.zero,
                autoFocus: false,
                expands: true,
                scrollable: true,
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    AppTheme.lightTheme.textTheme.bodyLarge!.copyWith(
                      height: 1.6,
                      fontSize: 16.sp,
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(8, 8),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  h1: DefaultTextBlockStyle(
                    AppTheme.lightTheme.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(16, 8),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  h2: DefaultTextBlockStyle(
                    AppTheme.lightTheme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(12, 6),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  h3: DefaultTextBlockStyle(
                    AppTheme.lightTheme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(10, 4),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Formatting Toolbar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showToolbar ? 12.h : 0,
          child: _showToolbar
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: QuillSimpleToolbar(
                      controller: _controller,
                      config: QuillSimpleToolbarConfig(
                        showAlignmentButtons: false,
                        showBackgroundColorButton: false,
                        showClearFormat: false,
                        showCodeBlock: false,
                        showColorButton: false,
                        showDirection: false,
                        showDividers: false,
                        showFontFamily: false,
                        showFontSize: false,
                        showHeaderStyle: true,
                        showIndent: false,
                        showInlineCode: false,
                        showLink: false,
                        showListCheck: false,
                        showListNumbers: true,
                        showListBullets: true,
                        showQuote: false,
                        showRedo: true,
                        showSearchButton: false,
                        showSmallButton: false,
                        showStrikeThrough: false,
                        showSubscript: false,
                        showSuperscript: false,
                        showUnderLineButton: true,
                        showUndo: true,
                        buttonOptions: QuillSimpleToolbarButtonOptions(
                          base: QuillToolbarBaseButtonOptions(
                            iconSize: 5.w,
                            iconButtonFactor: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}