import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ExportFormatSectionWidget extends StatefulWidget {
  final VoidCallback onChanged;

  const ExportFormatSectionWidget({super.key, required this.onChanged});

  @override
  State<ExportFormatSectionWidget> createState() =>
      _ExportFormatSectionWidgetState();
}

class _ExportFormatSectionWidgetState extends State<ExportFormatSectionWidget> {
  String _defaultFormat = 'pdf';
  bool _includeMetadata = true;
  bool _includeImages = true;
  String _fileNamingConvention = 'date_title';
  String _dateFormat = 'yyyy_mm_dd';
  List<String> _selectedFormats = ['pdf', 'txt'];

  final List<Map<String, dynamic>> _formats = [
    {
      'value': 'pdf',
      'label': 'PDF',
      'description': 'Portable Document Format - Best for sharing',
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
    },
    {
      'value': 'txt',
      'label': 'TXT',
      'description': 'Plain text - Simple and universal',
      'icon': Icons.text_snippet,
      'color': Colors.blue,
    },
    {
      'value': 'docx',
      'label': 'DOCX',
      'description': 'Microsoft Word format - Editable',
      'icon': Icons.description,
      'color': Colors.indigo,
    },
    {
      'value': 'html',
      'label': 'HTML',
      'description': 'Web format - Rich formatting',
      'icon': Icons.web,
      'color': Colors.orange,
    },
    {
      'value': 'json',
      'label': 'JSON',
      'description': 'Structured data - For developers',
      'icon': Icons.data_object,
      'color': Colors.green,
    },
  ];

  final List<Map<String, String>> _namingConventions = [
    {
      'value': 'date_title',
      'label': 'Date + Title',
      'example': '2024_01_15_my_story.pdf',
    },
    {
      'value': 'title_date',
      'label': 'Title + Date',
      'example': 'my_story_2024_01_15.pdf',
    },
    {'value': 'title_only', 'label': 'Title Only', 'example': 'my_story.pdf'},
    {'value': 'date_only', 'label': 'Date Only', 'example': '2024_01_15.pdf'},
  ];

  Widget _buildFormatSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Export Format',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _formats.map((format) {
                final isSelected = _defaultFormat == format['value'];
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
                    value: format['value'],
                    groupValue: _defaultFormat,
                    onChanged: (newValue) {
                      setState(() {
                        _defaultFormat = newValue!;
                      });
                      widget.onChanged();
                    },
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: format['color'].withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            format['icon'],
                            size: 5.w,
                            color: format['color'],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format['label'],
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
                              format['description'],
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

  Widget _buildMultiFormatSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Export Formats',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Select formats to include in bulk exports',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children:
              _formats.map((format) {
                final isSelected = _selectedFormats.contains(format['value']);
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        format['icon'],
                        size: 3.w,
                        color: isSelected ? Colors.white : format['color'],
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        format['label'],
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFormats.add(format['value']);
                      } else {
                        _selectedFormats.remove(format['value']);
                      }
                    });
                    widget.onChanged();
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: format['color'],
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? format['color'] : theme.dividerColor,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNamingConvention() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Naming Convention',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        DropdownButtonFormField<String>(
          initialValue: _fileNamingConvention,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 2.h,
            ),
            prefixIcon: const Icon(Icons.drive_file_rename_outline),
          ),
          items:
              _namingConventions.map((convention) {
                return DropdownMenuItem<String>(
                  value: convention['value'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        convention['label']!,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Example: ${convention['example']}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _fileNamingConvention = value!;
            });
            widget.onChanged();
          },
        ),
      ],
    );
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
                  'Export Formats',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.file_download_outlined,
                  size: 5.w,
                  color: theme.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Default Format Selector
            _buildFormatSelector(),

            SizedBox(height: 3.h),

            // Multi-format Selector
            _buildMultiFormatSelector(),

            SizedBox(height: 3.h),

            // Export Options
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
                      Icon(Icons.info_outline, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Include Metadata',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Add creation date, word count, and tags',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _includeMetadata,
                        onChanged: (value) {
                          setState(() {
                            _includeMetadata = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),

                  Divider(height: 3.h),

                  Row(
                    children: [
                      Icon(Icons.image_outlined, size: 4.w),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Include Images',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Export attached photos and illustrations',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _includeImages,
                        onChanged: (value) {
                          setState(() {
                            _includeImages = value;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // File Naming Convention
            _buildNamingConvention(),

            SizedBox(height: 3.h),

            // Date Format (if applicable)
            if (_fileNamingConvention.contains('date')) ...[
              Text(
                'Date Format',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'yyyy_mm_dd', label: Text('2024_01_15')),
                  ButtonSegment(value: 'dd_mm_yyyy', label: Text('15_01_2024')),
                  ButtonSegment(value: 'mm_dd_yyyy', label: Text('01_15_2024')),
                ],
                selected: {_dateFormat},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _dateFormat = newSelection.first;
                  });
                  widget.onChanged();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
