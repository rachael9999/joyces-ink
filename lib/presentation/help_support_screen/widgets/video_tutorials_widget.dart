import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoTutorialsWidget extends StatelessWidget {
  const VideoTutorialsWidget({super.key});

  final List<Map<String, dynamic>> _tutorials = const [
    {
      'title': 'Getting Started with Joyce\'s Ink',
      'description':
          'Learn the basics of creating your first journal entry and navigating the app',
      'duration': '3:45',
      'thumbnail':
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=225&fit=crop&crop=center',
      'progress': 0.0,
      'category': 'Beginner',
    },
    {
      'title': 'Voice Recording & Text Entry',
      'description':
          'Master both voice-to-text and traditional text input methods',
      'duration': '2:30',
      'thumbnail':
          'https://images.pexels.com/photos/6953876/pexels-photo-6953876.jpeg?w=400&h=225&fit=crop&crop=center',
      'progress': 0.65,
      'category': 'Writing',
    },
    {
      'title': 'AI Story Generation',
      'description':
          'Transform your journal entries into creative stories with AI assistance',
      'duration': '4:20',
      'thumbnail':
          'https://images.pixabay.com/photo/2023/01/26/22/12/ai-generated-7747304_1280.jpg?w=400&h=225&fit=crop&crop=center',
      'progress': 0.0,
      'category': 'Advanced',
    },
    {
      'title': 'Organizing Your Stories',
      'description':
          'Tips for managing your story library and creating collections',
      'duration': '3:15',
      'thumbnail':
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=225&fit=crop&crop=center',
      'progress': 1.0,
      'category': 'Organization',
    },
    {
      'title': 'Privacy & Export Options',
      'description':
          'Understand privacy settings and how to export your creative work',
      'duration': '2:50',
      'thumbnail':
          'https://images.pexels.com/photos/60504/security-protection-anti-virus-software-60504.jpeg?w=400&h=225&fit=crop&crop=center',
      'progress': 0.0,
      'category': 'Settings',
    },
  ];

  void _playTutorial(BuildContext context, Map<String, dynamic> tutorial) {
    // Simulate video player
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video Player Placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Stack(
                    children: [
                      // Video thumbnail
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: tutorial['thumbnail'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      // Play overlay
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withAlpha(77),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Video controls placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial['title'],
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration: ${tutorial['duration']}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Beginner':
        return Colors.green;
      case 'Writing':
        return Colors.blue;
      case 'Advanced':
        return Colors.purple;
      case 'Organization':
        return Colors.orange;
      case 'Settings':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Featured Tutorial Card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured video thumbnail
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _tutorials[0]['thumbnail'],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FEATURED',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _playTutorial(context, _tutorials[0]),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(26),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tutorials[0]['title'],
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tutorials[0]['description'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    _getCategoryColor(_tutorials[0]['category'])
                                        .withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _tutorials[0]['category'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getCategoryColor(
                                      _tutorials[0]['category']),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _tutorials[0]['duration'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tutorial List
        ..._tutorials.skip(1).map((tutorial) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                onTap: () => _playTutorial(context, tutorial),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 60,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: tutorial['thumbnail'],
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.video_library, size: 20),
                          ),
                        ),
                        if (tutorial['progress'] > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              value: tutorial['progress'],
                              backgroundColor: Colors.black.withAlpha(77),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                tutorial['progress'] == 1.0
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        const Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Text(
                  tutorial['title'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      tutorial['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(tutorial['category'])
                                .withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tutorial['category'],
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(tutorial['category']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tutorial['duration'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        if (tutorial['progress'] > 0) ...[
                          const SizedBox(width: 8),
                          Icon(
                            tutorial['progress'] == 1.0
                                ? Icons.check_circle
                                : Icons.play_circle_filled,
                            size: 12,
                            color: tutorial['progress'] == 1.0
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
