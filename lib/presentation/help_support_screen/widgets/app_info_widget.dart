import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppInfoWidget extends StatelessWidget {
  const AppInfoWidget({super.key});

  void _showChangelog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withAlpha(51),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'What\'s New in Joyce\'s Ink',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Changelog Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVersionSection(
                        context,
                        'Version 2.1.0',
                        'October 2024',
                        true,
                        [
                          'Enhanced AI story generation with new creative styles',
                          'Improved voice-to-text accuracy by 30%',
                          'Added dark mode theme support',
                          'New community features and user galleries',
                          'Bug fixes and performance improvements',
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildVersionSection(
                        context,
                        'Version 2.0.5',
                        'September 2024',
                        false,
                        [
                          'Fixed crash when generating long stories',
                          'Improved sync reliability across devices',
                          'Added export options for PDF and EPUB formats',
                          'Updated privacy settings interface',
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildVersionSection(
                        context,
                        'Version 2.0.0',
                        'August 2024',
                        false,
                        [
                          'Major UI redesign with improved user experience',
                          'Introduced AI-powered story generation',
                          'New writing prompts and creative challenges',
                          'Enhanced journal entry editor with rich formatting',
                          'Added mood tracking and writing analytics',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionSection(BuildContext context, String version, String date,
      bool isLatest, List<String> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              version,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(width: 8),
            if (isLatest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CURRENT',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...changes
            .map((change) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 7, right: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          change,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  void _checkForUpdates(BuildContext context) {
    // Simulate update check
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Checking for updates...',
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "You're using the latest version of Joyce's Ink!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const currentVersion = '2.1.0';
    const buildNumber = '21001';
    const releaseDate = 'October 15, 2024';

    return Column(
      children: [
        // Current Version Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // App Icon and Name
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joyce\'s Ink',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Creative Writing Companion',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Version Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Version', currentVersion),
                      const SizedBox(height: 8),
                      _buildInfoRow(context, 'Build', buildNumber),
                      const SizedBox(height: 8),
                      _buildInfoRow(context, 'Release Date', releaseDate),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showChangelog(context),
                        icon: const Icon(Icons.history, size: 18),
                        label: Text(
                          'What\'s New',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _checkForUpdates(context),
                        icon: const Icon(Icons.system_update, size: 18),
                        label: Text(
                          'Check Updates',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Additional Information Cards
        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              'App Information',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              'Licenses, terms of service, and privacy policy',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Fluttertoast.showToast(
                msg: "Opening app information...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security,
                color: Colors.green,
                size: 20,
              ),
            ),
            title: Text(
              'Security & Compliance',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              'Data encryption, security measures, and certifications',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Fluttertoast.showToast(
                msg: "Opening security information...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
        ),

        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.developer_mode,
                color: Colors.orange,
                size: 20,
              ),
            ),
            title: Text(
              'Developer Information',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              'About the development team and acknowledgments',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Fluttertoast.showToast(
                msg: "Opening developer information...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ],
    );
  }
}
