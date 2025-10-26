import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  void _contactSupport(BuildContext context) {
    // Simulate contacting support
    Fluttertoast.showToast(
      msg: "Redirecting to support chat...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _reportBug(BuildContext context) {
    // Show bug report dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report a Bug',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the bug you encountered...',
                hintStyle: GoogleFonts.inter(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'System diagnostics will be included automatically',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
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
                msg: "Bug report submitted successfully!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Submit',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _featureRequest(BuildContext context) {
    // Show feature request dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Feature Request',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the feature you\'d like to see...',
                hintStyle: GoogleFonts.inter(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your ideas help make Joyce\'s Ink better!',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
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
                msg: "Feature request submitted! Thank you!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Submit',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.support_agent,
        'title': 'Contact Support',
        'subtitle': 'Get help from our support team',
        'color': Theme.of(context).colorScheme.primary,
        'onTap': () => _contactSupport(context),
      },
      {
        'icon': Icons.bug_report,
        'title': 'Report Bug',
        'subtitle': 'Tell us about issues you\'ve found',
        'color': Colors.orange,
        'onTap': () => _reportBug(context),
      },
      {
        'icon': Icons.lightbulb,
        'title': 'Feature Request',
        'subtitle': 'Suggest new features and improvements',
        'color': Theme.of(context).colorScheme.secondary,
        'onTap': () => _featureRequest(context),
      },
    ];

    return Column(
      children: actions.map((action) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            child: ListTile(
              onTap: action['onTap'],
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action['color'].withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'],
                  color: action['color'],
                  size: 24,
                ),
              ),
              title: Text(
                action['title'],
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              subtitle: Text(
                action['subtitle'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodySmall?.color,
                size: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
