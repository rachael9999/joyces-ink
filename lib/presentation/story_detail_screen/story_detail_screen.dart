import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/comments_section_widget.dart';
import './widgets/related_stories_widget.dart';
import './widgets/story_action_bar_widget.dart';
import './widgets/story_content_widget.dart';
import './widgets/story_header_widget.dart';
import './widgets/story_metadata_widget.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  bool _isFavorite = false;
  int _rating = 0;
  double _readingProgress = 0.0;
  String _storyTitle = '';
  String _storyContent = '';
  String _genre = '';
  DateTime _creationDate = DateTime.now();
  int _wordCount = 0;
  int _readingTimeMinutes = 0;

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Mock data for the story
  final Map<String, dynamic> _currentStory = {
    "id": 1,
    "title": "The Midnight Garden's Secret",
    "content":
        """In the heart of the old Victorian mansion, behind walls covered in ivy and memories, lay a garden that only revealed its true nature when the clock struck midnight.

Sarah had discovered this peculiar place three weeks ago, during one of her restless nights. The journal entry she had written that evening about feeling lost and searching for purpose had somehow transformed into this enchanting tale of mystery and self-discovery.

The garden was unlike anything she had ever seen. Moonflowers bloomed in silver cascades, their petals shimmering with an otherworldly light. Ancient oak trees whispered secrets in languages she couldn't understand but somehow felt in her soul. And at the center of it all stood a fountain, its waters reflecting not the moon above, but glimpses of what could be.

As Sarah walked the winding paths, she realized that each flower, each tree, each stone had been placed there by her own thoughts and dreams. The garden was a manifestation of her inner world, a place where her deepest desires took root and grew into something beautiful.

She had written about feeling disconnected from her purpose, and here in this magical space, she found clarity. The garden showed her that sometimes the most profound journeys begin not with grand adventures, but with quiet moments of introspection.

The fountain's waters began to ripple, and in its depths, Sarah saw herself - not as she was, but as she could become. A writer, a dreamer, a creator of worlds. The garden had taken her simple journal entry about uncertainty and transformed it into a story of hope and possibility.

As dawn approached and the garden began to fade with the morning light, Sarah understood that she would carry this place with her always. It lived not just in the story generated from her thoughts, but in the knowledge that within every person lies a garden of infinite potential, waiting to bloom.""",
    "genre": "Fantasy",
    "creationDate": DateTime.now().subtract(const Duration(days: 2)),
    "wordCount": 342,
    "readingTimeMinutes": 3,
    "rating": 4,
    "isFavorite": true,
    "imageUrl":
        "https://images.unsplash.com/photo-1518709268805-4e9042af2176?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "semanticLabel":
        "Mystical garden at night with moonlight filtering through ancient trees and glowing flowers"
  };

  final List<Map<String, dynamic>> _relatedStories = [
    {
      "id": 2,
      "title": "The Coffee Shop Chronicles",
      "genre": "Romance",
      "readingTime": 4,
      "rating": 5,
      "imageUrl":
          "https://images.unsplash.com/photo-1689475299375-b6b45ca0c56b",
      "semanticLabel":
          "Cozy coffee shop interior with warm lighting, wooden tables, and steaming cups of coffee"
    },
    {
      "id": 3,
      "title": "Digital Dreams",
      "genre": "Sci-Fi",
      "readingTime": 6,
      "rating": 3,
      "imageUrl":
          "https://images.unsplash.com/photo-1654802603840-77ce8e54de67",
      "semanticLabel":
          "Futuristic cityscape with neon lights and digital displays reflecting in rain-soaked streets"
    },
    {
      "id": 4,
      "title": "The Last Letter",
      "genre": "Drama",
      "readingTime": 5,
      "rating": 4,
      "imageUrl":
          "https://images.unsplash.com/photo-1706726633556-478df028832a",
      "semanticLabel":
          "Vintage writing desk with old letters, fountain pen, and warm candlelight"
    }
  ];

  final List<Map<String, dynamic>> _comments = [
    {
      "id": 1,
      "content":
          "This story really resonated with me. The garden metaphor perfectly captures how I've been feeling about my own creative journey lately.",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "content":
          "I love how the AI transformed my simple journal entry about feeling lost into such a beautiful narrative. It's like having a conversation with my subconscious.",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeStoryData();
    _scrollController.addListener(_updateReadingProgress);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_updateReadingProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeStoryData() {
    setState(() {
      _storyTitle = _currentStory['title'] as String;
      _storyContent = _currentStory['content'] as String;
      _genre = _currentStory['genre'] as String;
      _creationDate = _currentStory['creationDate'] as DateTime;
      _wordCount = _currentStory['wordCount'] as int;
      _readingTimeMinutes = _currentStory['readingTimeMinutes'] as int;
      _rating = _currentStory['rating'] as int;
      _isFavorite = _currentStory['isFavorite'] as bool;
    });
  }

  void _updateReadingProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _readingProgress =
            maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (_isEditing) {
      Fluttertoast.showToast(
        msg: "Edit mode enabled",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      _saveStory();
    }
  }

  void _saveStory() {
    // Calculate new word count
    _wordCount = _storyContent.split(' ').length;
    _readingTimeMinutes = (_wordCount / 200).ceil(); // Average reading speed

    Fluttertoast.showToast(
      msg: "Story saved successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 1.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildMenuOption(
                icon: 'share',
                title: 'Share Story',
                onTap: () {
                  Navigator.pop(context);
                  _shareStory();
                },
              ),
              _buildMenuOption(
                icon: 'file_download',
                title: 'Export as PDF',
                onTap: () {
                  Navigator.pop(context);
                  _exportStory('pdf');
                },
              ),
              _buildMenuOption(
                icon: 'text_snippet',
                title: 'Export as Text',
                onTap: () {
                  Navigator.pop(context);
                  _exportStory('txt');
                },
              ),
              _buildMenuOption(
                icon: 'delete',
                title: 'Delete Story',
                onTap: () {
                  Navigator.pop(context);
                  _deleteStory();
                },
                isDestructive: true,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? Colors.red
            : AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: isDestructive
              ? Colors.red
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _shareStory() {
    Share.share(
      'Check out this amazing story: "$_storyTitle"\n\n$_storyContent\n\nGenerated with StoryWeaver',
      subject: _storyTitle,
    );
  }

  void _exportStory(String format) {
    Fluttertoast.showToast(
      msg: "Exporting story as ${format.toUpperCase()}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      Fluttertoast.showToast(
        msg: "Story exported successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _deleteStory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Story',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete "$_storyTitle"? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
              Fluttertoast.showToast(
                msg: "Story deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    Fluttertoast.showToast(
      msg: _isFavorite ? "Added to favorites" : "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _updateRating(int rating) {
    setState(() {
      _rating = rating;
    });

    Fluttertoast.showToast(
      msg: "Story rated $_rating star${_rating == 1 ? '' : 's'}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _createNewVersion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Version',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Generate a new version of this story with different parameters? Your original story will be preserved.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge,
            ),
          ),
              ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.storyGenerationScreen);
            },
            child: Text(
              'Generate',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRelatedStoryTap(Map<String, dynamic> story) {
    // Navigate to the selected story (would pass story ID in real implementation)
  Navigator.pushNamed(context, AppRoutes.storyDetailScreen);
  }

  void _addComment(String comment) {
    setState(() {
      _comments.insert(0, {
        "id": _comments.length + 1,
        "content": comment,
        "timestamp": DateTime.now(),
      });
    });

    Fluttertoast.showToast(
      msg: "Note added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          StoryHeaderWidget(
            title: _storyTitle,
            isEditing: _isEditing,
            onTitleChanged: (title) => setState(() => _storyTitle = title),
            onBackPressed: () => Navigator.pop(context),
            onMenuPressed: _showActionMenu,
          ),
          // Content
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Story'),
                        Tab(text: 'Notes'),
                      ],
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Story Tab
                        SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              // Metadata
                              StoryMetadataWidget(
                                genre: _genre,
                                creationDate: _creationDate,
                                wordCount: _wordCount,
                                readingTimeMinutes: _readingTimeMinutes,
                              ),
                              // Story Content
                              Container(
                                constraints: BoxConstraints(minHeight: 50.h),
                                child: StoryContentWidget(
                                  content: _storyContent,
                                  isEditing: _isEditing,
                                  onContentChanged: (content) =>
                                      setState(() => _storyContent = content),
                                  readingProgress: _readingProgress,
                                ),
                              ),
                              // Related Stories
                              RelatedStoriesWidget(
                                relatedStories: _relatedStories,
                                onStoryTap: _onRelatedStoryTap,
                              ),
                              SizedBox(
                                  height: 10.h), // Space for bottom action bar
                            ],
                          ),
                        ),
                        // Notes Tab
                        SingleChildScrollView(
                          child: CommentsSectionWidget(
                            comments: _comments,
                            onAddComment: _addComment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Action Bar
          StoryActionBarWidget(
            isFavorite: _isFavorite,
            rating: _rating,
            onShare: _shareStory,
            onFavoriteToggle: _toggleFavorite,
            onRatingChanged: _updateRating,
            onCreateNewVersion: _createNewVersion,
          ),
        ],
      ),
      // Floating Action Button for Edit Mode
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _toggleEditing,
              backgroundColor: _isEditing
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: _isEditing ? 'save' : 'edit',
                color: _isEditing
                    ? AppTheme.lightTheme.colorScheme.onSecondary
                    : AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            )
          : null,
    );
  }
}
