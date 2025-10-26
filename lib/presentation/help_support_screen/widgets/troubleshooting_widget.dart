import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TroubleshootingWidget extends StatefulWidget {
  const TroubleshootingWidget({super.key});

  @override
  State<TroubleshootingWidget> createState() => _TroubleshootingWidgetState();
}

class _TroubleshootingWidgetState extends State<TroubleshootingWidget> {
  final Map<String, List<Map<String, dynamic>>> _troubleshootingGuides = {
    'App Crashes & Freezes': [
      {
        'title': 'App won\'t start or crashes immediately',
        'steps': [
          'Force close the app completely',
          'Clear app cache in device settings',
          'Restart your device',
          'Update to the latest app version',
          'If issue persists, reinstall the app',
        ],
        'completed': <int>{},
      },
      {
        'title': 'App freezes while writing',
        'steps': [
          'Save any current work manually',
          'Close and reopen the app',
          'Check available device storage (need 100MB+)',
          'Disable other apps running in background',
          'Try writing in shorter sessions',
        ],
        'completed': <int>{},
      },
    ],
    'Sync & Data Issues': [
      {
        'title': 'My entries aren\'t syncing',
        'steps': [
          'Check internet connection',
          'Verify you\'re signed into the same account',
          'Pull down to refresh in the journal home',
          'Check sync settings in Profile > Settings',
          'Sign out and sign back in if needed',
        ],
        'completed': <int>{},
      },
      {
        'title': 'Missing journal entries',
        'steps': [
          'Check if entries are in Draft folder',
          'Look in Recently Deleted section',
          'Verify correct date range filter',
          'Check if signed into correct account',
          'Contact support if entries were backed up',
        ],
        'completed': <int>{},
      },
    ],
    'Voice & Recording': [
      {
        'title': 'Voice recording not working',
        'steps': [
          'Check microphone permissions in device settings',
          'Test microphone in other apps',
          'Ensure good internet connection for processing',
          'Try recording in a quiet environment',
          'Update the app to latest version',
        ],
        'completed': <int>{},
      },
      {
        'title': 'Voice-to-text accuracy issues',
        'steps': [
          'Speak clearly and at normal pace',
          'Reduce background noise',
          'Hold device 6-8 inches from mouth',
          'Use punctuation voice commands',
          'Edit text after recording for accuracy',
        ],
        'completed': <int>{},
      },
    ],
    'Story Generation': [
      {
        'title': 'AI story generation fails',
        'steps': [
          'Check internet connection strength',
          'Ensure journal entry has enough content (50+ words)',
          'Try a different genre or style setting',
          'Wait a moment and try again',
          'Contact support if error persists',
        ],
        'completed': <int>{},
      },
      {
        'title': 'Generated stories don\'t match my style',
        'steps': [
          'Review your writing preferences settings',
          'Add more journal entries for better AI training',
          'Adjust creativity and style sliders',
          'Try regenerating with different options',
          'Provide feedback to improve future results',
        ],
        'completed': <int>{},
      },
    ],
  };

  void _toggleStep(String category, int guideIndex, int stepIndex) {
    setState(() {
      final guide = _troubleshootingGuides[category]![guideIndex];
      final completed = guide['completed'] as Set<int>;
      
      if (completed.contains(stepIndex)) {
        completed.remove(stepIndex);
      } else {
        completed.add(stepIndex);
      }
      
      // Show completion message when all steps are done
      if (completed.length == (guide['steps'] as List).length) {
        Fluttertoast.showToast(
          msg: "Great! All troubleshooting steps completed.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

  void _generateSystemReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'System Diagnostics',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will generate a technical report to help our support team diagnose your issue.',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report will include:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• App version and build info\n'
                    '• Device model and OS version\n'
                    '• Error logs (no personal data)\n'
                    '• Network connectivity status\n'
                    '• Available storage space',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "System report generated! Use this when contacting support.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Generate Report',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // System Diagnostics Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(26),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Need More Help?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate a system report to help our support team diagnose complex issues.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _generateSystemReport(context),
                    icon: const Icon(Icons.assessment, size: 20),
                    label: Text(
                      'Generate System Report',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Troubleshooting Categories
        ..._troubleshootingGuides.entries.map((category) {
          return _buildCategorySection(category.key, category.value);
        }).toList(),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> guides) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: Theme.of(context).colorScheme.error,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ),
          ],
        ),
        children: guides.asMap().entries.map((entry) {
          final guideIndex = entry.key;
          final guide = entry.value;
          return _buildTroubleshootingGuide(category, guideIndex, guide);
        }).toList(),
      ),
    );
  }

  Widget _buildTroubleshootingGuide(String category, int guideIndex, Map<String, dynamic> guide) {
    final steps = guide['steps'] as List<String>;
    final completed = guide['completed'] as Set<int>;
    final progress = completed.length / steps.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 1,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide['title'],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleSmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${completed.length}/${steps.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const SizedBox(height: 8),
            ...steps.asMap().entries.map((entry) {
              final stepIndex = entry.key;
              final step = entry.value;
              final isCompleted = completed.contains(stepIndex);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleStep(category, guideIndex, stepIndex),
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2, right: 12),
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green 
                              : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted 
                                ? Colors.green 
                                : Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Center(
                                child: Text(
                                  '${stepIndex + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        step,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isCompleted 
                              ? Theme.of(context).textTheme.bodySmall?.color
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (progress == 1.0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All steps completed! If the issue persists, please contact our support team.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'App Crashes & Freezes':
        return Icons.error_outline;
      case 'Sync & Data Issues':
        return Icons.sync_problem;
      case 'Voice & Recording':
        return Icons.mic_off;
      case 'Story Generation':
        return Icons.auto_awesome_motion;
      default:
        return Icons.help_outline;
    }
  }
}