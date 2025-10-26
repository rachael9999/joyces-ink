import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchHelpWidget extends StatelessWidget {
  final String searchQuery;

  const SearchHelpWidget({
    super.key,
    required this.searchQuery,
  });

  List<Map<String, dynamic>> _getSearchResults() {
    final List<Map<String, dynamic>> allContent = [
// FAQ Results
      {
        'type': 'FAQ',
        'title': 'How do I create my first journal entry?',
        'content':
            'Tap the "+" button on the Journal Home screen, then choose between voice recording or text entry...',
        'category': 'Getting Started',
        'icon': Icons.help_outline,
        'color': Colors.blue,
      },
      {
        'type': 'FAQ',
        'title': 'How does voice-to-text work?',
        'content':
            'Tap the microphone icon when creating an entry. Joyce\'s Ink will convert your speech to text...',
        'category': 'Writing Features',
        'icon': Icons.help_outline,
        'color': Colors.blue,
      },
      {
        'type': 'FAQ',
        'title': 'How does AI story generation work?',
        'content':
            'Select a journal entry and tap "Generate Story". Our AI analyzes your writing style...',
        'category': 'Story Generation',
        'icon': Icons.help_outline,
        'color': Colors.blue,
      },
      {
        'type': 'FAQ',
        'title': 'How do I export my data?',
        'content':
            'Go to Profile > Settings > Export Data. You can export your journal entries...',
        'category': 'Account Issues',
        'icon': Icons.help_outline,
        'color': Colors.blue,
      },

// Tutorial Results
      {
        'type': 'Tutorial',
        'title': 'Getting Started with Joyce\'s Ink',
        'content':
            'Learn the basics of creating your first journal entry and navigating the app',
        'category': 'Beginner',
        'duration': '3:45',
        'icon': Icons.play_circle_outline,
        'color': Colors.purple,
      },
      {
        'type': 'Tutorial',
        'title': 'Voice Recording & Text Entry',
        'content':
            'Master both voice-to-text and traditional text input methods',
        'category': 'Writing',
        'duration': '2:30',
        'icon': Icons.play_circle_outline,
        'color': Colors.purple,
      },
      {
        'type': 'Tutorial',
        'title': 'AI Story Generation',
        'content':
            'Transform your journal entries into creative stories with AI assistance',
        'category': 'Advanced',
        'duration': '4:20',
        'icon': Icons.play_circle_outline,
        'color': Colors.purple,
      },

// Troubleshooting Results
      {
        'type': 'Troubleshooting',
        'title': 'App won\'t start or crashes immediately',
        'content':
            'Force close the app completely, clear app cache in device settings, restart your device...',
        'category': 'App Crashes & Freezes',
        'steps': 5,
        'icon': Icons.build_outlined,
        'color': Colors.orange,
      },
      {
        'type': 'Troubleshooting',
        'title': 'Voice recording not working',
        'content':
            'Check microphone permissions in device settings, test microphone in other apps...',
        'category': 'Voice & Recording',
        'steps': 5,
        'icon': Icons.build_outlined,
        'color': Colors.orange,
      },
      {
        'type': 'Troubleshooting',
        'title': 'My entries aren\'t syncing',
        'content':
            'Check internet connection, verify you\'re signed into the same account...',
        'category': 'Sync & Data Issues',
        'steps': 5,
        'icon': Icons.build_outlined,
        'color': Colors.orange,
      },

// Community Results
      {
        'type': 'Community',
        'title': 'User Forums',
        'content':
            'Connect with other writers, share tips, and get writing inspiration',
        'category': 'Community',
        'members': '15.2K members',
        'icon': Icons.forum,
        'color': Colors.green,
      },
      {
        'type': 'Community',
        'title': 'Writing Challenge: 30-Day Journal Streak',
        'content':
            'Join our community challenge to build a consistent writing habit',
        'category': 'Challenges',
        'participants': 1840,
        'icon': Icons.emoji_events,
        'color': Colors.green,
      },

// Feature Articles
      {
        'type': 'Article',
        'title': 'Maximizing Your Writing Potential with AI',
        'content':
            'Discover advanced techniques for collaborating with Joyce\'s Ink AI to enhance your creativity...',
        'category': 'Tips & Tricks',
        'readTime': '5 min read',
        'icon': Icons.article,
        'color': Colors.teal,
      },
      {
        'type': 'Article',
        'title': 'Privacy and Security in Joyce\'s Ink',
        'content':
            'Learn about our commitment to protecting your creative work and personal data...',
        'category': 'Security',
        'readTime': '3 min read',
        'icon': Icons.article,
        'color': Colors.teal,
      },
    ];

    return allContent.where((item) {
      final query = searchQuery.toLowerCase();
      return item['title'].toLowerCase().contains(query) ||
          item['content'].toLowerCase().contains(query) ||
          item['category'].toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildResultItem(BuildContext context, Map<String, dynamic> result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: result['color'].withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            result['icon'],
            color: result['color'],
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: result['color'].withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result['type'].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: result['color'],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result['title'],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              result['content'],
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(128),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    result['category'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (result.containsKey('duration'))
                  Text(
                    result['duration'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                if (result.containsKey('steps'))
                  Text(
                    '${result['steps']} steps',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                if (result.containsKey('members'))
                  Text(
                    result['members'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                if (result.containsKey('participants'))
                  Text(
                    '${result['participants']} joined',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                if (result.containsKey('readTime'))
                  Text(
                    result['readTime'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onTap: () {
          // Handle result tap based on type
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _getSearchResults();

    if (results.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withAlpha(128),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find anything matching "$searchQuery"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try searching for:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        'journal entry',
                        'voice recording',
                        'story generation',
                        'export data',
                        'sync problem',
                        'app crash',
                      ]
                          .map((suggestion) => ActionChip(
                                label: Text(
                                  suggestion,
                                  style: GoogleFonts.inter(fontSize: 12),
                                ),
                                onPressed: () {
                                  // Handle suggestion tap
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group results by type
    final Map<String, List<Map<String, dynamic>>> groupedResults = {};
    for (final result in results) {
      final type = result['type'];
      if (!groupedResults.containsKey(type)) {
        groupedResults[type] = [];
      }
      groupedResults[type]!.add(result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Results',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      'Found ${results.length} result${results.length != 1 ? 's' : ''} for "$searchQuery"',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Grouped Results
        ...groupedResults.entries.map((entry) {
          final type = entry.key;
          final typeResults = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '$type Results (${typeResults.length})',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
              ...typeResults.map((result) => _buildResultItem(context, result)),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),

        // Search Tips
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search Tips',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Use specific keywords like "export", "voice", or "sync"\n'
                  '• Try searching for error messages you\'ve seen\n'
                  '• Include the feature name you need help with\n'
                  '• Search works across FAQs, tutorials, and guides',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
