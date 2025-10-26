import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeedbackSectionWidget extends StatefulWidget {
  const FeedbackSectionWidget({super.key});

  @override
  State<FeedbackSectionWidget> createState() => _FeedbackSectionWidgetState();
}

class _FeedbackSectionWidgetState extends State<FeedbackSectionWidget> {
  int _selectedRating = 0;
  int _selectedSatisfaction = -1;
  bool _hasRatedApp = false;

  final List<Map<String, dynamic>> _satisfactionEmojis = [
    {'emoji': '😢', 'label': 'Very Unsatisfied', 'color': Colors.red},
    {'emoji': '😟', 'label': 'Unsatisfied', 'color': Colors.orange},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.grey},
    {'emoji': '😊', 'label': 'Satisfied', 'color': Colors.lightGreen},
    {'emoji': '😍', 'label': 'Very Satisfied', 'color': Colors.green},
  ];

  void _submitRating(int rating) {
    setState(() {
      _selectedRating = rating;
      _hasRatedApp = true;
    });

    if (rating >= 4) {
      // High rating - encourage app store review
      _showReviewDialog();
    } else {
      // Lower rating - ask for feedback
      _showFeedbackDialog();
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Thank You!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'We\'re thrilled you\'re enjoying Joyce\'s Ink! Would you mind taking a moment to rate us on the app store? It really helps other writers discover our app.',
          style: GoogleFonts.inter(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Redirecting to app store...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text(
              'Rate App',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Help Us Improve',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We appreciate your feedback! What can we do better?',
              style: GoogleFonts.inter(fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think could be improved...',
                hintStyle: GoogleFonts.inter(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                msg: "Thank you for your feedback!",
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

  void _submitSatisfactionSurvey() {
    if (_selectedSatisfaction == -1) {
      Fluttertoast.showToast(
        msg: "Please select your satisfaction level",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: "Thank you for your feedback!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    setState(() {
      _selectedSatisfaction = -1;
    });
  }

  void _showDetailedFeedbackForm() {
    final TextEditingController feedbackController = TextEditingController();
    String selectedCategory = 'General Feedback';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                        Icons.feedback,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Detailed Feedback',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
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

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Selection
                        Text(
                          'Feedback Category',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            'General Feedback',
                            'Bug Report',
                            'Feature Request',
                            'User Interface',
                            'Performance',
                            'Writing Experience',
                            'AI Story Generation',
                            'Other',
                          ]
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category,
                                        style: GoogleFonts.inter()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Feedback Text
                        Text(
                          'Your Feedback',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: feedbackController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText:
                                'Please share your thoughts, suggestions, or issues in detail...',
                            hintStyle: GoogleFonts.inter(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: "Thank you for your detailed feedback!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            child: Text(
                              'Submit Feedback',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Rating Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rate,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rate Joyce\'s Ink',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'How would you rate your experience with our app?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => _submitRating(index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),

                if (_hasRatedApp) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Thank you for rating Joyce\'s Ink!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Satisfaction Survey
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mood,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Satisfaction Survey',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'How satisfied are you with Joyce\'s Ink overall?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),

                // Emoji Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _satisfactionEmojis.asMap().entries.map((entry) {
                    final index = entry.key;
                    final emoji = entry.value;
                    final isSelected = _selectedSatisfaction == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSatisfaction = index;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? emoji['color'].withAlpha(51)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? emoji['color']
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji['emoji'],
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            emoji['label'],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isSelected
                                  ? emoji['color']
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitSatisfactionSurvey,
                    child: Text(
                      'Submit Survey',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Detailed Feedback
        Card(
          child: ListTile(
            onTap: _showDetailedFeedbackForm,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              'Detailed Feedback',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              'Share detailed thoughts, suggestions, or report specific issues',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),

        // Beta Testing
        Card(
          child: ListTile(
            onTap: () {
              Fluttertoast.showToast(
                msg: "Opening beta program information...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.science,
                color: Colors.purple,
                size: 20,
              ),
            ),
            title: Text(
              'Join Beta Testing',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            subtitle: Text(
              'Get early access to new features and help shape Joyce\'s Ink',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ],
    );
  }
}
