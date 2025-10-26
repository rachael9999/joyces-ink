import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunitySectionWidget extends StatelessWidget {
  const CommunitySectionWidget({super.key});

  final List<Map<String, dynamic>> _communityOptions = const [
    {
      'title': 'User Forums',
      'description':
          'Connect with other writers, share tips, and get writing inspiration',
      'icon': Icons.forum,
      'color': Color(0xFF1976D2),
      'members': '15.2K members',
      'activity': '342 posts today',
    },
    {
      'title': 'Facebook Group',
      'description':
          'Join our active Facebook community for daily writing challenges',
      'icon': Icons.facebook,
      'color': Color(0xFF4267B2),
      'members': '8.7K members',
      'activity': 'Very active',
    },
    {
      'title': 'Twitter/X',
      'description':
          'Follow us for app updates, writing tips, and featured stories',
      'icon': Icons.close, // X icon approximation
      'color': Color(0xFF000000),
      'members': '12.1K followers',
      'activity': 'Daily updates',
    },
    {
      'title': 'Discord Server',
      'description':
          'Real-time chat with writers, live events, and writing sprints',
      'icon': Icons.chat,
      'color': Color(0xFF7289DA),
      'members': '5.4K members',
      'activity': 'Always online',
    },
    {
      'title': 'Instagram',
      'description':
          'Visual inspiration, writing quotes, and behind-the-scenes content',
      'icon': Icons.camera_alt,
      'color': Color(0xFFE4405F),
      'members': '22.8K followers',
      'activity': '3-4 posts/week',
    },
  ];

  final List<Map<String, dynamic>> _featuredContent = const [
    {
      'type': 'Featured Story',
      'title': 'The Midnight Writer\'s Tale',
      'author': '@sarah_writes',
      'likes': 248,
      'comments': 32,
      'image':
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=300&h=200&fit=crop&crop=center',
    },
    {
      'type': 'Writing Challenge',
      'title': '30-Day Journal Streak Challenge',
      'author': 'Joyce\'s Ink Team',
      'participants': 1840,
      'daysLeft': 12,
      'image':
          'https://images.pexels.com/photos/261763/pexels-photo-261763.jpeg?w=300&h=200&fit=crop&crop=center',
    },
    {
      'type': 'User Gallery',
      'title': 'Creative Writing Showcase',
      'author': 'Community',
      'entries': 156,
      'featured': 8,
      'image':
          'https://images.pixabay.com/photo/2015/09/05/07/28/writing-923882_1280.jpg?w=300&h=200&fit=crop&crop=center',
    },
  ];

  void _openCommunityLink(
      BuildContext context, Map<String, dynamic> community) {
    Fluttertoast.showToast(
      msg: "Opening ${community['title']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _openFeaturedContent(
      BuildContext context, Map<String, dynamic> content) {
    Fluttertoast.showToast(
      msg: "Opening ${content['title']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Community Platforms
        Text(
          'Join Our Community',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 16),

        // Community Platform Cards
        ..._communityOptions.map((community) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                onTap: () => _openCommunityLink(context, community),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: community['color'].withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    community['icon'],
                    color: community['color'],
                    size: 24,
                  ),
                ),
                title: Text(
                  community['title'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      community['description'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: community['color'].withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            community['members'],
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: community['color'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          community['activity'],
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
                  Icons.open_in_new,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  size: 20,
                ),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 32),

        // Featured Community Content
        Text(
          'Featured Community Content',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 16),

        // Featured Content Grid
        ..._featuredContent.map((content) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openFeaturedContent(context, content),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Image
                    CachedNetworkImage(
                      imageUrl: content['image'],
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),

                    // Content Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getContentTypeColor(content['type'])
                                  .withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              content['type'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getContentTypeColor(content['type']),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Title
                          Text(
                            content['title'],
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Author
                          Text(
                            'by ${content['author']}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Stats
                          Row(
                            children: [
                              if (content.containsKey('likes')) ...[
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${content['likes']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.comment,
                                  size: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${content['comments']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                              if (content.containsKey('participants')) ...[
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${content['participants']} joined',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: Colors.orange[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${content['daysLeft']} days left',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                              if (content.containsKey('entries')) ...[
                                Icon(
                                  Icons.collections,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${content['entries']} entries',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${content['featured']} featured',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
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
        }).toList(),

        // Community Guidelines Card
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
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Community Guidelines',
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
                  'Our community is built on respect, creativity, and mutual support. Please be kind, share constructive feedback, and celebrate each other\'s writing journeys.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Fluttertoast.showToast(
                      msg: "Opening Community Guidelines...",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                  child: Text(
                    'Read Full Guidelines',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'Featured Story':
        return Colors.purple;
      case 'Writing Challenge':
        return Colors.orange;
      case 'User Gallery':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
