import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/story_card_widget.dart';

class StoryLibraryScreen extends StatefulWidget {
  const StoryLibraryScreen({Key? key}) : super(key: key);

  @override
  State<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends State<StoryLibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All Stories';
  String _searchQuery = '';
  bool _isGridView = false;
  bool _isLoading = false;
  List<String> _activeFilters = [];

  final List<String> _filterOptions = [
    'All Stories',
    'Favorites',
    'Horror',
    'Romance',
    'Comedy',
    'Mystery',
    'Drama',
    'Chick-Flick',
  ];

  final List<Map<String, dynamic>> _mockStories = [
    {
      "id": 1,
      "title": "The Midnight Visitor",
      "genre": "Horror",
      "coverImage":
          "https://images.unsplash.com/photo-1622041311536-ea92b27c50b1",
      "coverImageSemanticLabel":
          "Dark silhouette of a person standing in a dimly lit doorway with eerie shadows",
      "createdDate": DateTime.now().subtract(const Duration(days: 2)),
      "wordCount": 1250,
      "rating": 4.5,
      "isFavorite": true,
      "excerpt":
          "The old house creaked as Sarah approached the front door, unaware of the presence watching her from within..."
    },
    {
      "id": 2,
      "title": "Love in the Coffee Shop",
      "genre": "Romance",
      "coverImage":
          "https://images.unsplash.com/photo-1689475299375-b6b45ca0c56b",
      "coverImageSemanticLabel":
          "Cozy coffee shop interior with warm lighting, wooden tables, and a couple sitting together",
      "createdDate": DateTime.now().subtract(const Duration(days: 5)),
      "wordCount": 980,
      "rating": 4.8,
      "isFavorite": false,
      "excerpt":
          "Emma never expected that spilling coffee on a stranger would lead to the love of her life..."
    },
    {
      "id": 3,
      "title": "The Great Mix-Up",
      "genre": "Comedy",
      "coverImage":
          "https://images.unsplash.com/photo-1713693210110-bc3405bcc5e0",
      "coverImageSemanticLabel":
          "Person with surprised expression holding multiple colorful shopping bags in a busy street",
      "createdDate": DateTime.now().subtract(const Duration(days: 7)),
      "wordCount": 1100,
      "rating": 4.2,
      "isFavorite": true,
      "excerpt":
          "When Jake accidentally picked up the wrong suitcase at the airport, he had no idea it would lead to the most hilarious week of his life..."
    },
    {
      "id": 4,
      "title": "The Missing Heirloom",
      "genre": "Mystery",
      "coverImage":
          "https://images.unsplash.com/photo-1697575465509-ecf50ac0f181",
      "coverImageSemanticLabel":
          "Vintage magnifying glass lying on old documents and maps with mysterious symbols",
      "createdDate": DateTime.now().subtract(const Duration(days: 10)),
      "wordCount": 1450,
      "rating": 4.6,
      "isFavorite": false,
      "excerpt":
          "Detective Morgan thought it was just another routine case until she discovered the family secret that changed everything..."
    },
    {
      "id": 5,
      "title": "Second Chances",
      "genre": "Drama",
      "coverImage":
          "https://images.unsplash.com/photo-1468988358032-2585f173681b",
      "coverImageSemanticLabel":
          "Person sitting alone on a park bench during golden hour, looking contemplative",
      "createdDate": DateTime.now().subtract(const Duration(days: 12)),
      "wordCount": 1320,
      "rating": 4.4,
      "isFavorite": true,
      "excerpt":
          "After losing everything, Maria had to rebuild her life from scratch, but she never expected to find hope in the most unexpected place..."
    },
    {
      "id": 6,
      "title": "Girls' Night Out",
      "genre": "Chick-Flick",
      "coverImage":
          "https://images.unsplash.com/photo-1671116810289-302594443218",
      "coverImageSemanticLabel":
          "Group of happy women friends laughing together at a trendy restaurant with colorful cocktails",
      "createdDate": DateTime.now().subtract(const Duration(days: 15)),
      "wordCount": 890,
      "rating": 4.3,
      "isFavorite": false,
      "excerpt":
          "What started as a simple girls' night out turned into a life-changing adventure for Lisa and her best friends..."
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStories {
    List<Map<String, dynamic>> filtered = _mockStories;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((story) {
        final title = (story['title'] as String).toLowerCase();
        final genre = (story['genre'] as String).toLowerCase();
        final excerpt = (story['excerpt'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            genre.contains(query) ||
            excerpt.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter == 'Favorites') {
      filtered = filtered
          .where((story) => story['isFavorite'] as bool? ?? false)
          .toList();
    } else if (_selectedFilter != 'All Stories') {
      filtered =
          filtered.where((story) => story['genre'] == _selectedFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJournalTab(),
                  _buildStoriesTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Journal'),
          Tab(text: 'Stories'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildJournalTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'book',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Journal Tab',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            'Navigate to journal features',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.journalHomeScreen),
              child: const Text('Go to Journal'),
            ),
        ],
      ),
    );
  }

  Widget _buildStoriesTab() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilterChips(),
        if (_activeFilters.isNotEmpty) _buildActiveFilters(),
        Expanded(
          child: _buildStoryList(),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'person',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Profile Tab',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Text(
            'User profile and settings',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Stories',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isGridView = !_isGridView),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: _isGridView ? 'view_list' : 'grid_view',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: _showSortOptions,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'sort',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidget(
      hintText: 'Search stories, genres, or content...',
      onChanged: (value) => setState(() => _searchQuery = value),
      onFilterTap: _showFilterOptions,
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          return FilterChipWidget(
            label: filter,
            isSelected: _selectedFilter == filter,
            onTap: () => setState(() => _selectedFilter = filter),
            selectedColor: _getFilterColor(filter),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Text(
            'Active filters:',
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Wrap(
              spacing: 1.w,
              children: _activeFilters.map((filter) {
                return Chip(
                  label: Text(filter),
                  onDeleted: () => _removeFilter(filter),
                  deleteIcon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                );
              }).toList(),
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryList() {
    final filteredStories = _filteredStories;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (filteredStories.isEmpty) {
      return EmptyStateWidget(
        genre: _selectedFilter,
        onCreateStory: () =>
                  Navigator.pushNamed(context, AppRoutes.journalEntryCreation),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshStories,
      child: _isGridView
          ? _buildGridView(filteredStories)
          : _buildListView(filteredStories),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> stories) {
    return GridView.builder(
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        return StoryCardWidget(
          story: stories[index],
          isGridView: true,
          onTap: () => _navigateToStoryDetail(stories[index]),
          onShare: () => _shareStory(stories[index]),
          onEdit: () => _editStory(stories[index]),
          onFavorite: () => _toggleFavorite(stories[index]),
          onExport: () => _exportStory(stories[index]),
          onDelete: () => _deleteStory(stories[index]),
          onDuplicate: () => _duplicateStory(stories[index]),
          onChangeGenre: () => _changeGenre(stories[index]),
          onViewOriginal: () => _viewOriginalJournal(stories[index]),
        );
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> stories) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        return StoryCardWidget(
          story: stories[index],
          isGridView: false,
          onTap: () => _navigateToStoryDetail(stories[index]),
          onShare: () => _shareStory(stories[index]),
          onEdit: () => _editStory(stories[index]),
          onFavorite: () => _toggleFavorite(stories[index]),
          onExport: () => _exportStory(stories[index]),
          onDelete: () => _deleteStory(stories[index]),
          onDuplicate: () => _duplicateStory(stories[index]),
          onChangeGenre: () => _changeGenre(stories[index]),
          onViewOriginal: () => _viewOriginalJournal(stories[index]),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Card(
            child: Container(
              padding: EdgeInsets.all(3.w),
              height: 15.h,
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: 30.w,
                          height: 1.5.h,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40.w,
                          height: 1.5.h,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter.toLowerCase()) {
      case 'horror':
        return Colors.red;
      case 'romance':
        return Colors.pink;
      case 'comedy':
        return Colors.orange;
      case 'mystery':
        return Colors.purple;
      case 'drama':
        return Colors.blue;
      case 'chick-flick':
        return Colors.teal;
      case 'favorites':
        return Colors.amber;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Filter & Sort Options',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            _buildFilterSection(
                'Date Range', ['Last Week', 'Last Month', 'Last Year']),
            _buildFilterSection('Rating', ['5 Stars', '4+ Stars', '3+ Stars']),
            _buildFilterSection('Word Count',
                ['Short (< 500)', 'Medium (500-1000)', 'Long (> 1000)']),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: options.map((option) {
            final isSelected = _activeFilters.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _activeFilters.add(option);
                  } else {
                    _activeFilters.remove(option);
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Sort Stories',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            _buildSortOption('Newest First', Icons.schedule),
            _buildSortOption('Oldest First', Icons.history),
            _buildSortOption('Highest Rated', Icons.star),
            _buildSortOption('Most Words', Icons.text_fields),
            _buildSortOption('Alphabetical', Icons.sort_by_alpha),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.lightTheme.colorScheme.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // Implement sorting logic here
      },
    );
  }

  void _removeFilter(String filter) {
    setState(() {
      _activeFilters.remove(filter);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _selectedFilter = 'All Stories';
      _searchQuery = '';
    });
  }

  Future<void> _refreshStories() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _navigateToStoryDetail(Map<String, dynamic> story) {
  Navigator.pushNamed(context, AppRoutes.storyDetailScreen, arguments: story);
  }

  void _shareStory(Map<String, dynamic> story) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing "${story['title']}"')),
    );
  }

  void _editStory(Map<String, dynamic> story) {
  Navigator.pushNamed(context, AppRoutes.storyGenerationScreen, arguments: story);
  }

  void _toggleFavorite(Map<String, dynamic> story) {
    setState(() {
      final index = _mockStories.indexWhere((s) => s['id'] == story['id']);
      if (index != -1) {
        _mockStories[index]['isFavorite'] =
            !(story['isFavorite'] as bool? ?? false);
      }
    });
  }

  void _exportStory(Map<String, dynamic> story) {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting "${story['title']}"')),
    );
  }

  void _deleteStory(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story'),
        content: Text(
            'Are you sure you want to delete "${story['title']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mockStories.removeWhere((s) => s['id'] == story['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateStory(Map<String, dynamic> story) {
    final duplicatedStory = Map<String, dynamic>.from(story);
    duplicatedStory['id'] = _mockStories.length + 1;
    duplicatedStory['title'] = '${story['title']} (Copy)';
    duplicatedStory['createdDate'] = DateTime.now();

    setState(() {
      _mockStories.insert(0, duplicatedStory);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story duplicated')),
    );
  }

  void _changeGenre(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Genre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.skip(2).map((genre) {
            return ListTile(
              title: Text(genre),
              onTap: () {
                setState(() {
                  final index =
                      _mockStories.indexWhere((s) => s['id'] == story['id']);
                  if (index != -1) {
                    _mockStories[index]['genre'] = genre;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Genre changed to $genre')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _viewOriginalJournal(Map<String, dynamic> story) {
  Navigator.pushNamed(context, AppRoutes.journalHomeScreen,
    arguments: {'storyId': story['id']});
  }
}
