import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/daily_goals_section_widget.dart';
import './widgets/reminder_notifications_section_widget.dart';
import './widgets/default_entry_settings_widget.dart';
import './widgets/story_generation_preferences_widget.dart';
import './widgets/writing_prompts_section_widget.dart';
import './widgets/export_format_section_widget.dart';
import './widgets/voice_recording_section_widget.dart';
import './widgets/keyboard_preferences_widget.dart';
import './widgets/theme_customization_widget.dart';

class WritingPreferencesScreen extends StatefulWidget {
  const WritingPreferencesScreen({super.key});

  @override
  State<WritingPreferencesScreen> createState() =>
      _WritingPreferencesScreenState();
}

class _WritingPreferencesScreenState extends State<WritingPreferencesScreen> {
  bool _hasUnsavedChanges = false;

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _saveChanges() {
    // Save logic here
    setState(() {
      _hasUnsavedChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Writing preferences saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Reset to Defaults',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'This will reset all writing preferences to their default values. Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _markAsChanged();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferences reset to defaults'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Unsaved Changes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text(
                'You have unsaved changes. Do you want to save them before leaving?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () {
                    _saveChanges();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            'Writing Preferences',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'reset') {
                  _resetToDefaults();
                } else if (value == 'save') {
                  _saveChanges();
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'reset',
                      child: Row(
                        children: [
                          Icon(Icons.restore),
                          SizedBox(width: 8),
                          Text('Reset to Defaults'),
                        ],
                      ),
                    ),
                    if (_hasUnsavedChanges)
                      const PopupMenuItem(
                        value: 'save',
                        child: Row(
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text('Save Changes'),
                          ],
                        ),
                      ),
                  ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Daily Goals Section
              DailyGoalsSectionWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Reminder Notifications
              ReminderNotificationsSectionWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Default Entry Settings
              DefaultEntrySettingsWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Story Generation Preferences
              StoryGenerationPreferencesWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Writing Prompts Section
              WritingPromptsSectionWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Export Format Section
              ExportFormatSectionWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Voice Recording Section
              VoiceRecordingSectionWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Keyboard Preferences
              KeyboardPreferencesWidget(onChanged: _markAsChanged),

              SizedBox(height: 3.h),

              // Theme Customization
              ThemeCustomizationWidget(onChanged: _markAsChanged),

              SizedBox(height: 5.h),
            ],
          ),
        ),
        floatingActionButton:
            _hasUnsavedChanges
                ? FloatingActionButton.extended(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                )
                : null,
      ),
    );
  }
}
