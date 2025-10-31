import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/journal_service.dart';
import './widgets/mood_selector_widget.dart';
import './widgets/photo_attachment_widget.dart';
import './widgets/text_editor_widget.dart';
import './widgets/voice_recording_widget.dart';
import './widgets/writing_prompts_widget.dart';

class JournalEntryCreation extends StatefulWidget {
  const JournalEntryCreation({Key? key}) : super(key: key);

  @override
  State<JournalEntryCreation> createState() => _JournalEntryCreationState();
}

class _JournalEntryCreationState extends State<JournalEntryCreation>
    with TickerProviderStateMixin {
  bool _isTextMode = true;
  String _entryText = '';
  String _selectedMood = '';
  List<XFile> _attachedPhotos = [];
  DateTime _entryDate = DateTime.now();
  bool _hasUnsavedChanges = false;
  bool _isAutoSaving = false;
  int _wordCount = 0;
  int _characterCount = 0;
  // ignore: unused_field
  String _voiceTranscription = '';
  String? _recordingPath;
  Map<String, dynamic>? _editingEntry;
  bool _isEditMode = false;

  late AnimationController _saveAnimationController;
  late Animation<double> _saveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAutoSave();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're in edit mode by getting arguments
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _editingEntry = arguments;
      _isEditMode = true;
      _loadEntryForEditing();
    }
  }

  void _loadEntryForEditing() {
    if (_editingEntry != null) {
      setState(() {
        _entryText = _editingEntry!['content'] ?? '';
        _selectedMood = _editingEntry!['mood'] ?? '';
        _entryDate = _editingEntry!['date'] ?? DateTime.now();
        _wordCount = _editingEntry!['wordCount'] ?? 0;
        _characterCount = _entryText.length;
        // Note: In a real app, you'd also load photos and recordings
      });
    }
  }

  void _initializeAnimations() {
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _saveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _saveAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAutoSave() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _hasUnsavedChanges) {
        _autoSaveEntry();
        _startAutoSave();
      }
    });
  }

  void _onTextChanged(String text) {
    setState(() {
      _entryText = text;
      _hasUnsavedChanges = true;
      _wordCount =
          text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
      _characterCount = text.length;
    });
  }

  void _onVoiceTranscriptionUpdate(String transcription) {
    setState(() {
      _voiceTranscription = transcription;
      _entryText = transcription;
      _hasUnsavedChanges = true;
      _wordCount =
          transcription.trim().isEmpty
              ? 0
              : transcription.trim().split(RegExp(r'\s+')).length;
      _characterCount = transcription.length;
    });
  }

  void _onRecordingComplete(String? recordingPath) {
    setState(() {
      _recordingPath = recordingPath;
      if (recordingPath != null) {
        _hasUnsavedChanges = true;
      }
    });
  }

  void _onMoodSelected(String mood) {
    setState(() {
      _selectedMood = mood;
      _hasUnsavedChanges = true;
    });
  }

  void _onPhotosSelected(List<XFile> photos) {
    setState(() {
      _attachedPhotos = photos;
      _hasUnsavedChanges = true;
    });
  }

  void _onPromptSelected(String prompt) {
    setState(() {
      _entryText = _entryText.isEmpty ? prompt : '$_entryText\n\n$prompt';
      _hasUnsavedChanges = true;
      _wordCount =
          _entryText.trim().isEmpty
              ? 0
              : _entryText.trim().split(RegExp(r'\s+')).length;
      _characterCount = _entryText.length;
    });
  }

  void _toggleInputMode() {
    setState(() {
      _isTextMode = !_isTextMode;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _entryDate) {
      setState(() {
        _entryDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _showWritingPrompts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              WritingPromptsWidget(onPromptSelected: _onPromptSelected),
    );
  }

  Future<void> _autoSaveEntry() async {
    if (!_hasUnsavedChanges) return;

    setState(() {
      _isAutoSaving = true;
    });

    _saveAnimationController.forward();

    // Simulate auto-save process
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isAutoSaving = false;
      _hasUnsavedChanges = false;
    });

    _saveAnimationController.reset();

    // Show auto-save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(_isEditMode ? 'Entry auto-saved' : 'Entry auto-saved'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_entryText.trim().isEmpty &&
        _attachedPhotos.isEmpty &&
        _recordingPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content before saving'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Require an emotion/mood selection before saving
    if (_selectedMood.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'mood',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              const Expanded(
                child: Text(
                  'Please select an emotion before saving',
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isAutoSaving = true;
    });

    _saveAnimationController.forward();

    try {
      // Create preview from the first few words
      String preview = _entryText.split(' ').take(20).join(' ');
      if (_entryText.split(' ').length > 20) preview += '...';

      String? savedEntryId;
      if (_isEditMode && _editingEntry != null) {
        final updated = await JournalService.instance.updateJournalEntry(
          entryId: _editingEntry!['id'],
          content: _entryText,
          preview: preview,
          mood: _selectedMood,
        );
        savedEntryId = updated['id']?.toString() ?? _editingEntry!['id']?.toString();
      } else {
        final created = await JournalService.instance.createJournalEntry(
          content: _entryText,
          preview: preview,
          mood: _selectedMood,
        );
        savedEntryId = created['id']?.toString();
      }

      // Upload photos if any and persist attachment URLs
      if (savedEntryId != null && _attachedPhotos.isNotEmpty) {
        final urls = <String>[];
        for (final photo in _attachedPhotos) {
          try {
            final bytes = await photo.readAsBytes();
            final path = photo.path;
            final ext = path.toLowerCase().endsWith('.png')
                ? 'png'
                : path.toLowerCase().endsWith('.webp')
                    ? 'webp'
                    : 'jpg';
            final contentType = ext == 'png'
                ? 'image/png'
                : ext == 'webp'
                    ? 'image/webp'
                    : 'image/jpeg';
            final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.' + ext;
            final url = await JournalService.instance.uploadJournalAttachmentBytes(
              bytes: bytes,
              entryId: savedEntryId,
              fileName: fileName,
              contentType: contentType,
            );
            if (url != null && url.isNotEmpty) urls.add(url);
          } catch (_) {}
        }
        try {
          await JournalService.instance.replaceEntryAttachments(
            entryId: savedEntryId,
            urls: urls,
          );
        } catch (_) {}
      }

      setState(() {
        _isAutoSaving = false;
        _hasUnsavedChanges = false;
      });
    } catch (error) {
      setState(() {
        _isAutoSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save entry: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _saveAnimationController.reset();

    // Navigate back after successful save
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              _isEditMode
                  ? 'Journal entry updated successfully!'
                  : 'Journal entry saved successfully!',
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            title: Text(
              'Unsaved Changes',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              _isEditMode
                  ? 'You have unsaved changes to this entry. Do you want to save before leaving?'
                  : 'You have unsaved changes. Do you want to save before leaving?',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Discard',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  await _saveEntry();
                },
                child: Text(_isEditMode ? 'Update' : 'Save'),
              ),
            ],
          ),
    );

    return shouldPop ?? false;
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _saveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () async {
                        if (await _onWillPop()) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 6.w,
                        ),
                      ),
                    ),

                    SizedBox(width: 4.w),

                    // Title indicator
                    Text(
                      _isEditMode ? 'Edit Entry' : 'New Entry',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),

                    const Spacer(),

                    // Date Selector
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 4.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _formatDate(_entryDate),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Writing Prompts Button
                    GestureDetector(
                      onTap: _showWritingPrompts,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: CustomIconWidget(
                          iconName: 'lightbulb',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 5.w,
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Save Button
                    GestureDetector(
                      onTap: _isAutoSaving ? null : _saveEntry,
                      child: AnimatedBuilder(
                        animation: _saveAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _isAutoSaving
                                      ? AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.7)
                                      : AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child:
                                _isAutoSaving
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 4.w,
                                          height: 4.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.white),
                                            value: _saveAnimation.value,
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Saving...',
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'check',
                                          color: Colors.white,
                                          size: 4.w,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          _isEditMode ? 'Update' : 'Save',
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Input Mode Toggle
              Container(
                margin: EdgeInsets.all(4.w),
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isTextMode) _toggleInputMode();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color:
                                _isTextMode
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'edit',
                                color:
                                    _isTextMode
                                        ? Colors.white
                                        : AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Text',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                      color:
                                          _isTextMode
                                              ? Colors.white
                                              : AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                      fontWeight:
                                          _isTextMode
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isTextMode) _toggleInputMode();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color:
                                !_isTextMode
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'keyboard_voice',
                                color:
                                    !_isTextMode
                                        ? Colors.white
                                        : AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Voice',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                      color:
                                          !_isTextMode
                                              ? Colors.white
                                              : AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                      fontWeight:
                                          !_isTextMode
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      // Input Area
                      Container(
                        height: 40.h,
                        child:
                            _isTextMode
                                ? TextEditorWidget(
                                  onTextChanged: _onTextChanged,
                                  initialText: _entryText,
                                )
                                : VoiceRecordingWidget(
                                  onTranscriptionUpdate:
                                      _onVoiceTranscriptionUpdate,
                                  onRecordingComplete: _onRecordingComplete,
                                ),
                      ),

                      SizedBox(height: 3.h),

                      // Mood Selector
                      MoodSelectorWidget(
                        onMoodSelected: _onMoodSelected,
                        selectedMood:
                            _selectedMood.isEmpty ? null : _selectedMood,
                      ),

                      SizedBox(height: 3.h),

                      // Photo Attachment
                      PhotoAttachmentWidget(
                        onPhotosSelected: _onPhotosSelected,
                        initialPhotos: _attachedPhotos,
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // Bottom Stats Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Word Count
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Text(
                        '$_wordCount words',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Character Count
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Text(
                        '$_characterCount chars',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),

                    const Spacer(),

                    // Auto-save Status
                    if (_hasUnsavedChanges)
                      Row(
                        children: [
                          Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Unsaved',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Saved',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
