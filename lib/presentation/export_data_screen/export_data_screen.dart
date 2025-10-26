import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../export_data_screen/widgets/data_selection_widget.dart';
import '../export_data_screen/widgets/format_selection_widget.dart';
import '../export_data_screen/widgets/date_range_picker_widget.dart';
import '../export_data_screen/widgets/export_progress_widget.dart';
import '../export_data_screen/widgets/export_history_widget.dart';
import '../../core/app_export.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({Key? key}) : super(key: key);

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  // Data selection state
  final Map<String, bool> _dataSelection = {
    'journalEntries': false,
    'generatedStories': false,
    'userPreferences': false,
    'accountInfo': false,
  };

  // Format selection state
  String _selectedFormat = 'JSON';
  final List<String> _formatOptions = ['JSON', 'PDF', 'ZIP', 'CSV'];

  // Date range state
  DateTimeRange? _selectedDateRange;
  String _datePreset = 'all';

  // Export state
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _estimatedSize = '0 MB';
  String _estimatedTime = '0 seconds';

  // Export history
  final List<Map<String, dynamic>> _exportHistory = [
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'format': 'JSON',
      'size': '2.5 MB',
      'status': 'completed',
      'filename': 'joyces_export_20241220.json'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'format': 'PDF',
      'size': '5.1 MB',
      'status': 'expired',
      'filename': 'joyces_export_20241213.pdf'
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateEstimates();
  }

  void _updateEstimates() {
    final selectedCount =
        _dataSelection.values.where((selected) => selected).length;

    // Simple size estimation based on selection
    final baseSizePerType = 0.5; // MB
    final estimatedSizeMB = selectedCount * baseSizePerType;

    setState(() {
      _estimatedSize = '${estimatedSizeMB.toStringAsFixed(1)} MB';
      _estimatedTime = '${(selectedCount * 10)} seconds';
    });
  }

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _startExport() async {
    if (_dataSelection.values.every((selected) => !selected)) {
      Fluttertoast.showToast(
        msg: "Please select at least one data type to export",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      Fluttertoast.showToast(
        msg: "Storage permission required for export",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
    });

    try {
      // Simulate export process with progress updates
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _exportProgress = i / 100.0;
        });
      }

      // Generate mock export data
      final exportData = _generateExportData();
      final filename =
          'joyces_export_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat.toLowerCase()';

      await _downloadFile(exportData, filename);

      Fluttertoast.showToast(
        msg: "Export completed successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Export failed: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isExporting = false;
        _exportProgress = 0.0;
      });
    }
  }

  String _generateExportData() {
    final Map<String, dynamic> data = {};

    if (_dataSelection['journalEntries'] == true) {
      data['journalEntries'] = [
        {
          'id': 1,
          'title': 'My First Entry',
          'content': 'Today was a great day...',
          'date': DateTime.now().toIso8601String(),
          'mood': 'happy'
        }
      ];
    }

    if (_dataSelection['generatedStories'] == true) {
      data['generatedStories'] = [
        {
          'id': 1,
          'title': 'The Adventure Begins',
          'content': 'Once upon a time...',
          'genre': 'fantasy',
          'date': DateTime.now().toIso8601String()
        }
      ];
    }

    if (_dataSelection['userPreferences'] == true) {
      data['userPreferences'] = {
        'theme': 'light',
        'notifications': true,
        'autoSave': true
      };
    }

    if (_dataSelection['accountInfo'] == true) {
      data['accountInfo'] = {
        'username': 'user123',
        'email': 'user@example.com',
        'joinDate': DateTime.now().toIso8601String()
      };
    }

    return jsonEncode(data);
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export Data',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            onPressed: () {
              // Navigate to export guide
              Fluttertoast.showToast(
                msg: "Export guide coming soon",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Selection Section
            DataSelectionWidget(
              dataSelection: _dataSelection,
              onSelectionChanged: (key, value) {
                setState(() {
                  _dataSelection[key] = value;
                  _updateEstimates();
                });
              },
            ),

            SizedBox(height: 3.h),

            // Date Range Selection
            DateRangePickerWidget(
              selectedDateRange: _selectedDateRange,
              datePreset: _datePreset,
              onDateRangeChanged: (range) {
                setState(() {
                  _selectedDateRange = range;
                });
              },
              onPresetChanged: (preset) {
                setState(() {
                  _datePreset = preset;
                  if (preset == 'all') {
                    _selectedDateRange = null;
                  } else if (preset == 'lastMonth') {
                    _selectedDateRange = DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 30)),
                      end: DateTime.now(),
                    );
                  } else if (preset == 'lastYear') {
                    _selectedDateRange = DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 365)),
                      end: DateTime.now(),
                    );
                  }
                });
              },
            ),

            SizedBox(height: 3.h),

            // Format Selection
            FormatSelectionWidget(
              formatOptions: _formatOptions,
              selectedFormat: _selectedFormat,
              onFormatChanged: (format) {
                setState(() {
                  _selectedFormat = format;
                });
              },
            ),

            SizedBox(height: 3.h),

            // File Size Estimation
            Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Estimation',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Size',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                            ),
                            Text(
                              _estimatedSize,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Estimated Time',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                            ),
                            Text(
                              _estimatedTime,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Export Progress (shown during export)
            if (_isExporting) ...[
              ExportProgressWidget(
                progress: _exportProgress,
                estimatedTime: _estimatedTime,
              ),
              SizedBox(height: 3.h),
            ],

            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isExporting ? null : _startExport,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isExporting
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
                          ),
                        ),
                      )
                    : Text(
                        'Start Export',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 4.h),

            // Export History
            ExportHistoryWidget(
              exportHistory: _exportHistory,
              onRedownload: (item) {
                Fluttertoast.showToast(
                  msg: "Re-downloading ${item['filename']}",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
