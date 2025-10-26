import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class VoiceRecordingSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const VoiceRecordingSectionWidget({super.key, required this.onChanged});

  @override
  State<VoiceRecordingSectionWidget> createState() =>
      _VoiceRecordingSectionWidgetState();
}

class _VoiceRecordingSectionWidgetState
    extends State<VoiceRecordingSectionWidget> {
  bool _voiceRecordingEnabled = true;
  String _audioQuality = 'high';
  bool _autoTranscription = true;
  String _transcriptionLanguage = 'english';
  bool _noiseReduction = true;
  bool _autoSaveRecordings = false;
  int _maxRecordingDuration = 300; // seconds

  final List<Map<String, dynamic>> _audioQualities = [
    {
      'value': 'low',
      'label': 'Low Quality',
      'description': '32 kbps - Smaller files',
      'icon': Icons.graphic_eq,
      'color': Colors.red,
    },
    {
      'value': 'medium',
      'label': 'Medium Quality',
      'description': '128 kbps - Balanced',
      'icon': Icons.equalizer,
      'color': Colors.orange,
    },
    {
      'value': 'high',
      'label': 'High Quality',
      'description': '320 kbps - Best quality',
      'icon': Icons.high_quality,
      'color': Colors.green,
    },
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'english', 'label': 'English', 'flag': '🇺🇸'},
    {'value': 'spanish', 'label': 'Spanish', 'flag': '🇪🇸'},
    {'value': 'french', 'label': 'French', 'flag': '🇫🇷'},
    {'value': 'german', 'label': 'German', 'flag': '🇩🇪'},
    {'value': 'italian', 'label': 'Italian', 'flag': '🇮🇹'},
    {'value': 'portuguese', 'label': 'Portuguese', 'flag': '🇵🇹'},
  ];

  Widget _buildQualitySelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio Quality',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _audioQualities.map((quality) {
                final isSelected = _audioQuality == quality['value'];
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isSelected ? theme.primaryColor : theme.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isSelected
                            ? theme.primaryColor.withAlpha(13)
                            : Colors.transparent,
                  ),
                  child: RadioListTile<String>(
                    value: quality['value'],
                    groupValue: _audioQuality,
                    onChanged: (newValue) {
                      setState(() {
                        _audioQuality = newValue!;
                      });
                      widget.onChanged();
                    },
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: quality['color'].withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            quality['icon'],
                            size: 4.w,
                            color: quality['color'],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quality['label'],
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? theme.primaryColor
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              quality['description'],
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voice Recording',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(Icons.mic_outlined, size: 5.w, color: theme.primaryColor),
              ],
            ),

            SizedBox(height: 3.h),

            // Enable/Disable Voice Recording
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _voiceRecordingEnabled ? Icons.mic : Icons.mic_off,
                    color: _voiceRecordingEnabled ? Colors.red : Colors.grey,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Recording',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _voiceRecordingEnabled
                              ? 'Record voice notes and convert to text'
                              : 'Voice recording is disabled',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _voiceRecordingEnabled,
                    onChanged: (value) {
                      setState(() {
                        _voiceRecordingEnabled = value;
                      });
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ),

            if (_voiceRecordingEnabled) ...[
              SizedBox(height: 3.h),

              // Audio Quality Selection
              _buildQualitySelector(),

              SizedBox(height: 3.h),

              // Max Recording Duration
              Text(
                'Max Recording Duration: ${_formatDuration(_maxRecordingDuration)}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Slider(
                value: _maxRecordingDuration.toDouble(),
                min: 60,
                max: 1800, // 30 minutes
                divisions: 29,
                onChanged: (value) {
                  setState(() {
                    _maxRecordingDuration = value.round();
                  });
                  widget.onChanged();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1m',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '30m',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Transcription Settings
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.transcribe, size: 4.w),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto Transcription',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Automatically convert speech to text',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoTranscription,
                          onChanged: (value) {
                            setState(() {
                              _autoTranscription = value;
                            });
                            widget.onChanged();
                          },
                        ),
                      ],
                    ),

                    if (_autoTranscription) ...[
                      Divider(height: 3.h),

                      // Language Selection for Transcription
                      Row(
                        children: [
                          Icon(Icons.language, size: 4.w),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transcription Language',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: _transcriptionLanguage,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items:
                                      _languages.map((language) {
                                        return DropdownMenuItem<String>(
                                          value: language['value'],
                                          child: Row(
                                            children: [
                                              Text(
                                                language['flag']!,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                language['label']!,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _transcriptionLanguage = value!;
                                    });
                                    widget.onChanged();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Additional Recording Options
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.noise_control_off, size: 4.w),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Noise Reduction',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Reduce background noise in recordings',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _noiseReduction,
                          onChanged: (value) {
                            setState(() {
                              _noiseReduction = value;
                            });
                            widget.onChanged();
                          },
                        ),
                      ],
                    ),

                    Divider(height: 3.h),

                    Row(
                      children: [
                        Icon(Icons.save_alt, size: 4.w),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-Save Recordings',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Keep original audio files after transcription',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoSaveRecordings,
                          onChanged: (value) {
                            setState(() {
                              _autoSaveRecordings = value;
                            });
                            widget.onChanged();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
