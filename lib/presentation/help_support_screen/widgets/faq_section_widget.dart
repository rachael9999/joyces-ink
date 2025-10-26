import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqSectionWidget extends StatefulWidget {
  final String searchQuery;

  const FaqSectionWidget({
    super.key,
    this.searchQuery = '',
  });

  @override
  State<FaqSectionWidget> createState() => _FaqSectionWidgetState();
}

class _FaqSectionWidgetState extends State<FaqSectionWidget> {
  final Map<String, List<Map<String, String>>> _faqCategories = {
    'Getting Started': [
      {
        'question': 'How do I create my first journal entry?',
        'answer':
            'Tap the "+" button on the Journal Home screen, then choose between voice recording or text entry. You can also add photos and select your mood to make your entry more expressive.',
      },
      {
        'question': 'How do I set up my writing preferences?',
        'answer':
            'Go to Profile > Settings > Writing Preferences. Here you can customize your writing experience, set daily goals, choose your preferred writing style, and configure auto-save settings.',
      },
      {
        'question': 'Can I use Joyce\'s Ink offline?',
        'answer':
            'Yes! Most features work offline including creating journal entries, viewing your existing stories, and accessing cached help articles. Your data will sync when you reconnect to the internet.',
      },
    ],
    'Writing Features': [
      {
        'question': 'How does voice-to-text work?',
        'answer':
            'Tap the microphone icon when creating an entry. Joyce\'s Ink will convert your speech to text in real-time. Make sure to grant microphone permissions for the best experience.',
      },
      {
        'question': 'Can I edit my journal entries after saving?',
        'answer':
            'Absolutely! Tap any journal entry card and select the edit icon. You can modify text, add new photos, change the mood, or update any other details.',
      },
      {
        'question': 'What writing prompts are available?',
        'answer':
            'Joyce\'s Ink offers daily prompts, creative challenges, reflective questions, and themed writing exercises. New prompts are added regularly to keep your writing fresh and inspired.',
      },
    ],
    'Story Generation': [
      {
        'question': 'How does AI story generation work?',
        'answer':
            'Select a journal entry and tap "Generate Story". Our AI analyzes your writing style and content to create personalized stories. You can choose different genres and adjust the creativity level.',
      },
      {
        'question': 'Can I customize generated stories?',
        'answer':
            'Yes! After generation, you can edit any part of the story, change the tone, adjust the length, or regenerate specific sections while keeping parts you like.',
      },
      {
        'question': 'Are my stories private?',
        'answer':
            'Completely private by default. You control sharing - stories remain on your device unless you explicitly choose to share them with the community or export them.',
      },
    ],
    'Account Issues': [
      {
        'question': 'How do I export my data?',
        'answer':
            'Go to Profile > Settings > Export Data. You can export your journal entries, stories, and settings as PDF, text files, or backup format for safekeeping.',
      },
      {
        'question': 'I forgot my password. What should I do?',
        'answer':
            'On the login screen, tap "Forgot Password" and enter your email. We\'ll send reset instructions. If you don\'t receive them, check your spam folder or contact support.',
      },
      {
        'question': 'How do I delete my account?',
        'answer':
            'Go to Profile > Settings > Privacy & Security > Delete Account. This action is permanent and cannot be undone. Make sure to export your data first if you want to keep it.',
      },
    ],
  };

  List<Map<String, String>> _getFilteredFAQs() {
    if (widget.searchQuery.isEmpty) {
      return [];
    }

    List<Map<String, String>> allFaqs = [];
    _faqCategories.forEach((category, faqs) {
      for (var faq in faqs) {
        if (faq['question']!.toLowerCase().contains(widget.searchQuery) ||
            faq['answer']!.toLowerCase().contains(widget.searchQuery) ||
            category.toLowerCase().contains(widget.searchQuery)) {
          allFaqs.add({
            ...faq,
            'category': category,
          });
        }
      }
    });
    return allFaqs;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchQuery.isNotEmpty) {
      final filteredFaqs = _getFilteredFAQs();

      if (filteredFaqs.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different keywords or browse categories below.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Found ${filteredFaqs.length} result${filteredFaqs.length != 1 ? 's' : ''} for "${widget.searchQuery}"',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...filteredFaqs.map((faq) => _buildFaqItem(faq)),
        ],
      );
    }

    return Column(
      children: _faqCategories.entries.map((category) {
        return _buildCategorySection(category.key, category.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(
      String category, List<Map<String, String>> faqs) {
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
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: Theme.of(context).colorScheme.primary,
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
        children: faqs.map((faq) => _buildFaqItem(faq)).toList(),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            faq['question']!,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleSmall?.color,
            ),
          ),
          children: [
            if (faq.containsKey('category'))
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        faq['category']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              faq['answer']!,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Getting Started':
        return Icons.rocket_launch;
      case 'Writing Features':
        return Icons.edit;
      case 'Story Generation':
        return Icons.auto_awesome;
      case 'Account Issues':
        return Icons.account_circle;
      default:
        return Icons.help_outline;
    }
  }
}
