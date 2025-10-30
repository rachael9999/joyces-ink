import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../user_profile_screen/widgets/profile_header_widget.dart';
import '../user_profile_screen/widgets/profile_stats_widget.dart';
import '../user_profile_screen/widgets/quick_actions_widget.dart';
import '../user_profile_screen/widgets/settings_section_widget.dart';
import '../user_profile_screen/widgets/theme_selector_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/journal_entry_card_widget.dart';
import './widgets/new_entry_card_widget.dart';
import './widgets/writing_streak_widget.dart';

import '../../services/auth_service.dart';
import '../../services/journal_service.dart';
import '../../services/story_service.dart';
import '../../services/sparkle_service.dart';

class JournalHomeScreen extends StatefulWidget {
  const JournalHomeScreen({Key? key}) : super(key: key);

  @override
  State<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends State<JournalHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _storyDetailTabController;
  late AnimationController _profileAnimationController;
  late Animation<double> _profileFadeAnimation;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredEntries = [];
  final ScrollController _scrollController = ScrollController();
  
  // Add missing variables for thoughts functionality
  List<Map<String, dynamic>> _filteredThoughts = [];
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _thoughtSearchController = TextEditingController();
  bool _isSearchingThoughts = false;
  
  // Add missing variables for story functionality
  Map<String, dynamic> _currentStory = {};
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _relatedStories = [];

  // Story Detail State
  bool _isEditingStory = false;
  bool _isFavorite = false;
  int _rating = 0;
  double _readingProgress = 0.0;
  String _storyTitle = '';
  String _storyContent = '';
  String _genre = '';
  DateTime _creationDate = DateTime.now();
  int _wordCount = 0;
  int _readingTimeMinutes = 0;
  bool _showStoryDetail = false;
  bool _showAllStories = false; // Add this new state variable

  // Profile data
  String _selectedTheme = 'System';
  bool _notificationsEnabled = true;
  bool _backupEnabled = true;
  bool _privacyMode = false;

  // Replace mock data with real data from Supabase
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _journalEntries = [];
  List<Map<String, dynamic>> _generatedStories = [];
  List<Map<String, dynamic>> _thoughts = [];
  Map<String, dynamic> _thoughtsStats = {
    'total': 0,
    'favorites': 0,
    'categories': 0
  };

  bool _isLoadingData = true;

  // Thought categories mapping (enum values -> display labels)
  static const List<Map<String, String>> _thoughtCategories = [
    {'value': 'philosophy', 'label': 'Philosophy'},
    {'value': 'business_ideas', 'label': 'Business Ideas'},
    {'value': 'random_thoughts', 'label': 'Random Thoughts'},
    {'value': 'story_ideas', 'label': 'Story Ideas'},
    {'value': 'random_facts', 'label': 'Random Facts'},
    {'value': 'uncategorized', 'label': 'Uncategorized'},
  ];

  String _categoryLabel(String value) {
    final found = _thoughtCategories.firstWhere(
      (e) => e['value'] == value,
      orElse: () => const {'value': 'uncategorized', 'label': 'Uncategorized'},
    );
    return found['label']!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _storyDetailTabController = TabController(length: 2, vsync: this);
    _filteredEntries = [];
    _filteredThoughts = [];
    _initializeAnimations();
    _loadUserData();
    _scrollController.addListener(_updateReadingProgress);

    // Listen to auth state changes
    AuthService.instance.authStateChanges.listen((data) {
      // Ensure we respond specifically to the signedOut event
      if (data.event == AuthChangeEvent.signedOut) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storyDetailTabController.dispose();
    _profileAnimationController.dispose();
    _scrollController.removeListener(_updateReadingProgress);
    _scrollController.dispose();
    _searchController.dispose();
    _thoughtController.dispose();
    _thoughtSearchController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _profileFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _profileAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _profileAnimationController.forward();
      }
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

  void _filterEntries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEntries = List.from(_journalEntries);
      } else {
        _filteredEntries = _journalEntries.where((entry) {
          final preview = (entry['preview'] as String).toLowerCase();
          final mood = (entry['mood'] as String).toLowerCase();
          final searchQuery = query.toLowerCase();
          return preview.contains(searchQuery) || mood.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);
    try {
      // Load user profile first
      _userData = await AuthService.instance.getUserProfile();
      if (!mounted) return;

      // Load journal entries with error handling
      try {
        _journalEntries = await JournalService.instance.getJournalEntries();
        if (mounted) {
          setState(() {
            _filteredEntries = List.from(_journalEntries);
          });
        }
      } catch (e) {
        debugPrint('Error loading journal entries: $e');
        if (mounted) {
          _journalEntries = [];
          _filteredEntries = [];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load journal entries. Please try again.')),
          );
        }
      }

      // Load other data
      try {
        _generatedStories = await StoryService.instance.getGeneratedStories();
        _thoughts = await SparkleService.instance.getSparkles();
        _thoughtsStats = await SparkleService.instance.getSparkleStatistics();
        if (mounted) {
          setState(() {
            _filteredThoughts = List.from(_thoughts);
          });
        }
      } catch (e) {
        debugPrint('Error loading additional data: $e');
        // Non-critical data, continue without showing error
      }

      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    } catch (error) {
      debugPrint('Error in _loadUserData: $error');
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data. Please check your connection.')),
        );
      }
    }
  }

  Future<void> _refreshEntries() async {
    await _loadUserData();
  }

  Future<void> _navigateToJournalEntry() async {
    await Navigator.pushNamed(context, AppRoutes.journalEntryCreation);
    // Refresh entries when returning from entry creation
    await _loadUserData();
  }

  void _navigateToStoryGeneration(Map<String, dynamic> entry) {
  Navigator.pushNamed(context, AppRoutes.storyGenerationScreen, arguments: entry);
  }

  void _navigateToStoryLibrary() {
  Navigator.pushNamed(context, AppRoutes.storyLibraryScreen);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, AppRoutes.userProfileScreen);
  }

  void _editEntry(Map<String, dynamic> entry) {
    Navigator.pushNamed(context, AppRoutes.journalEntryCreation, arguments: entry);
  }

  void _deleteEntry(Map<String, dynamic> entry) async {
    try {
      await JournalService.instance.deleteJournalEntry(entry['id']);
      await _loadUserData(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry deleted')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
                title: const Text('Notifications'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'backup',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
                title: const Text('Backup & Sync'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'privacy_tip',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
                title: const Text('Privacy'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'help',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
                title: const Text('Help & Support'),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 1.h),
              const Divider(height: 1),
              SizedBox(height: 1.h),
              // Sign Out action
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'logout',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                title: Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                        'Are you sure you want to sign out?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    Navigator.of(context).pop(); // Close bottom sheet
                    _handleLogout();
                  }
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showAboutStoryWeaver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'auto_stories',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            const Text("About Joyce's.ink"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Joyce's.ink v1.0.0",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Transform your daily thoughts into beautiful stories with the power of AI.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              _buildAboutItem(
                '📝',
                'Digital Journaling',
                'Write and organize your thoughts',
              ),
              _buildAboutItem(
                '🤖',
                'AI Story Generation',
                'Transform entries into stories',
              ),
              _buildAboutItem(
                '🎨',
                'Beautiful Themes',
                'Customize your experience',
              ),
              _buildAboutItem(
                '📊',
                'Writing Analytics',
                'Track your progress',
              ),
              _buildAboutItem(
                '☁️',
                'Cloud Sync',
                'Access across all devices',
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'App Information',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Version: 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Build: 2025.01.23',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Platform: Flutter 3.16.0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "© 2025 Joyce's.ink. All rights reserved.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
  );
  }

  Widget _buildAboutItem(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(
                          alpha: 0.7,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailChangeDialog() {
    final TextEditingController emailController = TextEditingController(
      text: _userData?['email'] ?? '',
    );
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'New Email',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update email logic here
              setState(() {
                _userData?['email'] = emailController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock_reset',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock_reset',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                // Update password logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Removed legacy Export UI and logic

  void _showEnhancedSubscriptionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 85.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),

              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.primary,
                          AppTheme.lightTheme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'star',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Joyce's.ink Premium",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Currently on Free Plan',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Premium Features
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      AppTheme.lightTheme.colorScheme.secondary.withValues(
                        alpha: 0.1,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Features',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.h),
                    _buildPremiumFeature(
                      'auto_stories',
                      'Unlimited AI Story Generation',
                      'Create unlimited stories from your entries',
                    ),
                    _buildPremiumFeature(
                      'cloud_sync',
                      'Advanced Cloud Sync',
                      'Sync across unlimited devices',
                    ),
                    _buildPremiumFeature(
                      'palette',
                      'Premium Themes',
                      'Access to exclusive themes and customization',
                    ),
                    _buildPremiumFeature(
                      'analytics',
                      'Advanced Analytics',
                      'Detailed writing insights and statistics',
                    ),
                    _buildPremiumFeature(
                      'backup',
                      'Priority Export',
                      'Faster exports with more format options',
                    ),
                    _buildPremiumFeature(
                      'support_agent',
                      'Priority Support',
                      '24/7 premium customer support',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Pricing Plans
              Row(
                children: [
                  Expanded(
                    child: _buildPricingCard(
                      'Monthly',
                      '\$4.99',
                      '/month',
                      false,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildPricingCard(
                      'Yearly',
                      '\$39.99',
                      '/year',
                      true,
                      discount: '33% OFF',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Current Usage
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Current Usage',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.h),
                    _buildUsageStat('Stories Generated', '3/5', 0.6),
                    _buildUsageStat('Cloud Storage', '2.4/5 MB', 0.48),
                    _buildUsageStat('Export Formats', '1/2', 0.5),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _upgradeToPremiun();
                      },
                      icon: CustomIconWidget(
                        iconName: 'star',
                        color: Colors.white,
                        size: 4.w,
                      ),
                      label: const Text('Upgrade Now'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              Text(
                '7-day free trial • Cancel anytime • No commitment',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(
    String iconName,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(
                          alpha: 0.7,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    String title,
    String price,
    String period,
    bool isPopular, {
    String? discount,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isPopular
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.dividerColor,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (discount != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                discount,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 1.h),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isPopular ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isPopular
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                period,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPopular
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStat(String label, String value, double progress) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.2,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _upgradeToPremiun() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Text(
          'This will redirect you to the payment page. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to payment...')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showStoryPopup(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: 80.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'auto_stories',
                      color: Colors.white,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['title'] ?? 'Generated Story',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '${story['genre'] ?? 'Fantasy'} • ${story['wordCount'] ?? 350} words',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ),

              // Story Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story['content'] ??
                            'Once upon a time, in a world where stories came to life from the deepest thoughts and dreams of their writers, there lived a young storyteller who discovered that every journal entry held the power to transform into something magical...',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                      SizedBox(height: 3.h),

                      // Story Stats
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildStoryStat(
                              '📖',
                              'Reading Time',
                              '${(story['wordCount'] ?? 350) ~/ 250 + 1} min',
                            ),
                            SizedBox(width: 4.w),
                            _buildStoryStat(
                              '🎭',
                              'Genre',
                              story['genre'] ?? 'Fantasy',
                            ),
                            SizedBox(width: 4.w),
                            _buildStoryStat(
                              '⭐',
                              'Quality',
                              '${story['rating'] ?? 4.2}/5',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Copy story to clipboard
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Story copied to clipboard'),
                            ),
                          );
                        },
                        icon: CustomIconWidget(
                          iconName: 'content_copy',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        label: const Text('Copy'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.storyLibraryScreen,
                          );
                        },
                        icon: CustomIconWidget(
                          iconName: 'library_books',
                          color: Colors.white,
                          size: 4.w,
                        ),
                        label: const Text('View All'),
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
  }

  Widget _buildStoryStat(String emoji, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _openStoryDetail(Map<String, dynamic> story) {
    setState(() {
      _showStoryDetail = true;
      _tabController.animateTo(1); // Switch to Stories tab with detail view
      _storyTitle = story['title'] ?? 'Generated Story';
      _storyContent = story['content'] ?? _currentStory['content'];
      _genre = story['genre'] ?? 'Fantasy';
      _creationDate = story['creationDate'] ?? DateTime.now();
      _wordCount = story['wordCount'] ?? 342;
      _readingTimeMinutes = story['readingTimeMinutes'] ?? 3;
      _rating = story['rating'] ?? 4;
      _isFavorite = story['isFavorite'] ?? false;
    });
  }

  void _closeStoryDetail() {
    setState(() {
      _showStoryDetail = false;
    });
  }

  void _toggleStoryEditing() {
    setState(() {
      _isEditingStory = !_isEditingStory;
    });

    if (_isEditingStory) {
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
    _wordCount = _storyContent.split(' ').length;
    _readingTimeMinutes = (_wordCount / 200).ceil();

    Fluttertoast.showToast(
      msg: "Story saved successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareStory() {
    Fluttertoast.showToast(
      msg: "Sharing story...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleStoryFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    Fluttertoast.showToast(
      msg: _isFavorite ? "Added to favorites" : "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _updateStoryRating(int rating) {
    setState(() {
      _rating = rating;
    });

    Fluttertoast.showToast(
      msg: "Story rated $_rating star${_rating == 1 ? '' : 's'}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _createNewStoryVersion() {
  Navigator.pushNamed(context, AppRoutes.storyGenerationScreen);
  }

  void _onRelatedStoryTap(Map<String, dynamic> story) {
    _openStoryDetail(story);
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

  void _exportStory(String format) {
    Fluttertoast.showToast(
      msg: "Exporting story as ${format.toUpperCase()}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
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
              _closeStoryDetail();
              Fluttertoast.showToast(
                msg: "Story deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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

  void _toggleShowAllStories() {
    setState(() {
      _showAllStories = !_showAllStories;
    });
  }

  void _addNewThought() async {
    if (_thoughtController.text.trim().isNotEmpty) {
      try {
        await SparkleService.instance.createSparkle(
          content: _thoughtController.text.trim(),
        );
        _thoughtController.clear();
        await _loadUserData(); // Refresh data
        Fluttertoast.showToast(
          msg: "Sparkle added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add thought: $error')),
        );
      }
    }
  }

  void _filterThoughts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredThoughts = List.from(_thoughts);
      } else {
        _filteredThoughts = _thoughts.where((thought) {
          final content = (thought['content'] as String).toLowerCase();
          final category = (thought['category'] as String).toLowerCase();
          final searchQuery = query.toLowerCase();
          return content.contains(searchQuery) ||
              category.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _toggleThoughtFavorite(Map<String, dynamic> thought) async {
    try {
      await SparkleService.instance.updateSparkle(
        sparkleId: thought['id'],
        isFavorite: !thought['is_favorite'],
      );
      await _loadUserData(); // Refresh data
      Fluttertoast.showToast(
        msg: thought['is_favorite']
            ? "Removed from favorites"
            : "Added to favorites",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update thought: $error')),
      );
    }
  }

  void _deleteThought(Map<String, dynamic> thought) async {
    try {
      await SparkleService.instance.deleteSparkle(thought['id']);
      await _loadUserData(); // Refresh data
      Fluttertoast.showToast(
        msg: "Sparkle deleted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete thought: $error')),
      );
    }
  }

  void _editThought(Map<String, dynamic> thought) {
    _thoughtController.text = thought['content'];
    String selectedCategory = (thought['category'] as String?) ?? 'uncategorized';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Edit Thought'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _thoughtController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Edit your thought...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.2.h,
                  ),
                ),
                items: _thoughtCategories
                    .map((e) => DropdownMenuItem<String>(
                          value: e['value'],
                          child: Text(e['label']!),
                        ))
                    .toList(),
                onChanged: (val) => setLocalState(() {
                  selectedCategory = val ?? 'uncategorized';
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _thoughtController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_thoughtController.text.trim().isNotEmpty) {
                  try {
                    await SparkleService.instance.updateSparkle(
                      sparkleId: thought['id'],
                      content: _thoughtController.text.trim(),
                      category: selectedCategory,
                    );
                    _thoughtController.clear();
                    Navigator.pop(context);
                    await _loadUserData(); // Refresh data
                    Fluttertoast.showToast(
                      msg: "Thought updated",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } catch (error) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update thought: $error')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddThoughtDialog() {
    String selectedCategory = 'uncategorized';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'lightbulb',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            const Text('Add New Thought'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _thoughtController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Paste or type your thought here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.all(3.w),
              ),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.2.h,
                ),
              ),
              items: _thoughtCategories
                  .map((e) => DropdownMenuItem<String>(
                        value: e['value'],
                        child: Text(e['label']!),
                      ))
                  .toList(),
              onChanged: (val) => setLocalState(() {
                selectedCategory = val ?? 'uncategorized';
              }),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Capture your ideas, insights, or random thoughts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _thoughtController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (_thoughtController.text.trim().isNotEmpty) {
                try {
                  await SparkleService.instance.createSparkle(
                    content: _thoughtController.text.trim(),
                    category: selectedCategory,
                  );
                  _thoughtController.clear();
                  await _loadUserData();
                  Fluttertoast.showToast(
                    msg: "Sparkle added successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add thought: $error')),
                  );
                }
              }
              Navigator.pop(context);
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 4.w,
            ),
            label: const Text('Add Thought'),
          ),
        ],
      ),
      ),
    );  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Search
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  _isSearching
                      ? Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search entries...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  AppTheme.lightTheme.colorScheme.surface,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                  iconName: 'search',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  size: 5.w,
                                ),
                              ),
                            ),
                            onChanged: _filterEntries,
                          ),
                        )
                      : Expanded(
                          child: Text(
                            "Joyce's.ink",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                          ),
                        ),
                  if (_showStoryDetail)
                    GestureDetector(
                      onTap: _closeStoryDetail,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchController.clear();
                            _filteredEntries = List.from(_journalEntries);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: _isSearching ? 'close' : 'search',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                tabs: [
                  const Tab(text: 'Journal'),
                  Tab(text: _showStoryDetail ? 'Story' : 'Stories'),
                  const Tab(text: 'Thoughts'),
                  const Tab(text: 'Profile'),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Journal Tab
                  _buildJournalTab(),
                  // Stories Tab (or Story Detail)
                  _showStoryDetail
                      ? _buildStoryDetailView()
                      : _buildStoriesTab(),
                  // Thoughts Tab - Updated
                  _buildThoughtsTab(),
                  // Profile Tab
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildThoughtsTab() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Thoughts Header with Search
          Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _isSearchingThoughts
                          ? TextField(
                              controller: _thoughtSearchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search thoughts...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor:
                                    AppTheme.lightTheme.colorScheme.surface,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.5.h,
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: CustomIconWidget(
                                    iconName: 'search',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    size: 5.w,
                                  ),
                                ),
                              ),
                              onChanged: _filterThoughts,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thoughts Collection',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                      ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Capture your creative sparkles',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearchingThoughts = !_isSearchingThoughts;
                              if (!_isSearchingThoughts) {
                                _thoughtSearchController.clear();
                                _filteredThoughts = List.from(_thoughts);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName:
                                  _isSearchingThoughts ? 'close' : 'search',
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              size: 6.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: _showAddThoughtDialog,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: 'add',
                              color: Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Stats Row
                Row(
                  children: [
                    _buildThoughtStat('Total', '${_thoughtsStats['total']}'),
                    SizedBox(width: 4.w),
                    _buildThoughtStat(
                      'Favorites',
                      '${_thoughtsStats['favorites']}',
                    ),
                    SizedBox(width: 4.w),
                    _buildThoughtStat(
                      'Categories',
                      '${_thoughtsStats['categories']}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Thoughts List
          Expanded(
            child: _filteredThoughts.isEmpty
                ? _buildEmptyThoughtsState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: _filteredThoughts.length,
                    itemBuilder: (context, index) {
                      final thought = _filteredThoughts[index];
                      return _buildThoughtCard(thought);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThoughtStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThoughtCard(Map<String, dynamic> thought) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and actions
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _categoryLabel(thought['category'] ?? 'uncategorized'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleThoughtFavorite(thought),
                child: CustomIconWidget(
                  iconName:
                      thought['is_favorite'] ? 'favorite' : 'favorite_border',
                  color: thought['is_favorite']
                      ? Colors.red
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 2.w),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editThought(thought);
                      break;
                    case 'delete':
                      _deleteThought(thought);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                  size: 5.w,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Content
          Text(
            thought['content'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),

          SizedBox(height: 2.h),

          // Footer with date and word count
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                _formatDate(thought['date']),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
              ),
              const Spacer(),
              Text(
                '${thought['wordCount']} words',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyThoughtsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'lightbulb_outline',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.3,
            ),
            size: 20.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'No thoughts yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start collecting your ideas and insights',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: _showAddThoughtDialog,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 5.w,
            ),
            label: const Text('Add Your First Thought'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton(
        onPressed: _navigateToJournalEntry,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 6.w,
        ),
      );
    } else if (_tabController.index == 1 && _showStoryDetail) {
      return FloatingActionButton(
        onPressed: _toggleStoryEditing,
        backgroundColor: _isEditingStory
            ? AppTheme.lightTheme.colorScheme.secondary
            : AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: _isEditingStory ? 'save' : 'edit',
          color: _isEditingStory
              ? AppTheme.lightTheme.colorScheme.onSecondary
              : AppTheme.lightTheme.colorScheme.onPrimary,
          size: 6.w,
        ),
      );
    } else if (_tabController.index == 2) {
      return FloatingActionButton(
        onPressed: _showAddThoughtDialog,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        child: CustomIconWidget(
          iconName: 'lightbulb',
          color: Colors.white,
          size: 6.w,
        ),
      );
    }
    return null;
  }

  Widget _buildJournalTab() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshEntries,
      child: _filteredEntries.isEmpty && _journalEntries.isNotEmpty
          ? _buildNoSearchResults()
          : _journalEntries.isEmpty
              ? EmptyStateWidget(onCreateEntry: _navigateToJournalEntry)
              : Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(height: 2.h),
                            GreetingHeaderWidget(
                              userName:
                                  _userData?['full_name']?.split(' ').first ??
                                      'User',
                              onSettingsPressed: _showSettings,
                            ),
                            NewEntryCardWidget(onTap: _navigateToJournalEntry),
                            WritingStreakWidget(
                              streakCount: _userData?['writing_streak'] ?? 0,
                              totalEntries: _journalEntries.length,
                            ),
                            SizedBox(height: 2.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Row(
                                children: [
                                  Text(
                                    'Recent Entries',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.h),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            final entry = _filteredEntries[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 3.h),
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.shadowLight
                                        .withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: JournalEntryCardWidget(
                                entry: entry,
                                onTap: () => _editEntry(entry),
                                onEdit: () => _editEntry(entry),
                                onTransform: () =>
                                    _navigateToStoryGeneration(entry),
                                onDelete: () => _deleteEntry(entry),
                              ),
                            );
                          }, childCount: _filteredEntries.length),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStoriesTab() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Text(
              'Your Stories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              '${_generatedStories.length} stories generated',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: 3.h),
            // Story Grid
            _generatedStories.isEmpty
                ? _buildEmptyStoriesState()
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 3.h,
                    ),
                    itemCount: _generatedStories.length,
                    itemBuilder: (context, index) {
                      return _buildStoryCard(_generatedStories[index]);
                    },
                  ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStoriesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'auto_stories',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.3,
            ),
            size: 20.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'No stories generated yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start writing journal entries to generate stories',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: _navigateToJournalEntry,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 5.w,
            ),
            label: const Text('Create Your First Entry'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story) {
    return GestureDetector(
      onTap: () => _openStoryDetail(story),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'auto_stories',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 10.w,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'] ?? 'Untitled Story',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    story['genre'] ?? 'Fantasy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${story['readingTimeMinutes'] ?? story['readingTime'] ?? 3} min read',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
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
    );
  }

  Widget _buildProfileTab() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: 6,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _profileFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _profileFadeAnimation.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Profile Header - Using real user data
                  ProfileHeaderWidget(
                    userData: _userData ?? {},
                    onAvatarTap: _navigateToEditProfile,
                  ),

                  SizedBox(height: 3.h),

                  // Profile Statistics
                  ProfileStatsWidget(userData: _userData ?? {}),

                  SizedBox(height: 3.h),

                  // Quick Actions
                  QuickActionsWidget(
                    onEditProfile: _navigateToEditProfile,
                    onWritingGoals: _navigateToWritingGoals,
                  ),

                  SizedBox(height: 3.h),

                  // Settings Sections
                  SettingsSectionWidget(
                    title: 'Account',
                    children: [
                      _buildSettingsTile(
                        'Email',
                        _userData?['email'] ?? 'Not available',
                        'email',
                        _showEmailChangeDialog,
                      ),
                      _buildSettingsTile(
                        'Password',
                        '••••••••',
                        'lock',
                        _showPasswordChangeDialog,
                      ),
                      _buildSettingsTile(
                        'Subscription',
                        _userData?['role'] == 'premium'
                            ? 'Premium Plan'
                            : 'Free Plan',
                        'star',
                        _showEnhancedSubscriptionModal,
                        trailing: _userData?['role'] != 'premium'
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Upgrade',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  SettingsSectionWidget(
                    title: 'Preferences',
                    children: [
                      _buildSwitchTile(
                        'Notifications',
                        'Get reminders and updates',
                        'notifications',
                        _notificationsEnabled,
                        (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      _buildThemeSelector(),
                      _buildSwitchTile(
                        'Privacy Mode',
                        'Hide entries from quick preview',
                        'visibility_off',
                        _privacyMode,
                        (value) {
                          setState(() {
                            _privacyMode = value;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  SettingsSectionWidget(
                    title: 'App Settings',
                    children: [
                      _buildSwitchTile(
                        'Auto Backup',
                        'Automatically backup your data',
                        'backup',
                        _backupEnabled,
                        (value) {
                          setState(() {
                            _backupEnabled = value;
                          });
                        },
                      ),
                      _buildSettingsTile(
                        'Storage',
                        '${_userData?['total_entries'] ?? 0} entries, 2.4 MB',
                        'storage',
                        () {},
                      ),
                      _buildSettingsTile(
                        'About Joyce\'s.ink',
                        'Version 1.0.0',
                        'info',
                        _showAboutStoryWeaver,
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Danger Zone
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.error.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Danger Zone',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 2.h),
                        OutlinedButton.icon(
                          onPressed: _deleteAccount,
                          icon: CustomIconWidget(
                            iconName: 'delete_forever',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 5.w,
                          ),
                          label: const Text('Delete Account'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                AppTheme.lightTheme.colorScheme.error,
                            side: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Profile helper methods
  void _navigateToEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditProfileModal(),
    );
  }

  void _navigateToWritingGoals() {
    showDialog(
      context: context,
      builder: (context) => _buildWritingGoalsDialog(),
    );
  }

  // Removed legacy export handler

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteAccountDialog(),
    );
  }

  void _showSubscriptionInfo() {
    _showEnhancedSubscriptionModal();
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
      ),
      trailing: trailing ??
          CustomIconWidget(
            iconName: 'chevron_right',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.5,
            ),
            size: 5.w,
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    String iconName,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildThemeSelector() {
    return ThemeSelectorWidget(
      selectedTheme: _selectedTheme,
      onThemeChanged: (theme) {
        setState(() {
          _selectedTheme = theme;
        });
      },
    );
  }

  Widget _buildEditProfileModal() {
    return Container(
      height: 70.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Edit Profile',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 3.h),
            // Edit profile form would go here
            const Center(child: Text('Edit profile form coming soon...')),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingGoalsDialog() {
    return AlertDialog(
      title: const Text('Writing Goals'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Set your daily writing goal:'),
          SizedBox(height: 2.h),
          Slider(
            value: _userData?['daily_goal'] ?? 300,
            min: 100,
            max: 1000,
            divisions: 9,
            label: '${_userData?['daily_goal'] ?? 300} words',
            onChanged: (value) {
              setState(() {
                _userData?['daily_goal'] = value.round();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Removed legacy export dialog

  Widget _buildDeleteAccountDialog() {
    return AlertDialog(
      title: Text(
        'Delete Account',
        style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
      ),
      content: const Text(
        'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Widget _buildSubscriptionModal() {
    return Container(
      height: 60.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'StoryWeaver Premium',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 3.h),
            // Premium features would go here
            const Center(child: Text('Premium features coming soon...')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
            alpha: 0.5,
          ),
          size: 5.w,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: AppTheme.lightTheme.colorScheme.surface,
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.5,
            ),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No entries found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryDetailView() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Story Detail Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _storyDetailTabController,
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              tabs: const [Tab(text: 'Story'), Tab(text: 'Notes')],
            ),
          ),

          // Tab Bar Content
          Expanded(
            child: TabBarView(
              controller: _storyDetailTabController,
              children: [
                // Story Tab
                _buildStoryContent(),
                // Notes Tab
                _buildNotesContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Header
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.colorScheme.primary,
                        AppTheme.lightTheme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _storyTitle,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _toggleStoryFavorite,
                            child: CustomIconWidget(
                              iconName:
                                  _isFavorite ? 'favorite' : 'favorite_border',
                              color:
                                  _isFavorite ? Colors.red[300]! : Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _genre,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '$_readingTimeMinutes min read',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '$_wordCount words',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Reading Progress Bar
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'auto_stories',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Reading Progress',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            '${(_readingProgress * 100).toInt()}%',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      LinearProgressIndicator(
                        value: _readingProgress,
                        backgroundColor: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Story Rating
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.lightTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate This Story',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => _updateStoryRating(index + 1),
                            child: Padding(
                              padding: EdgeInsets.only(right: 1.w),
                              child: CustomIconWidget(
                                iconName:
                                    index < _rating ? 'star' : 'star_border',
                                color: index < _rating
                                    ? Colors.amber
                                    : AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                size: 6.w,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Story Content
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.lightTheme.dividerColor),
                  ),
                  child: _isEditingStory
                      ? TextField(
                          controller: TextEditingController(
                            text: _storyContent,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Edit your story...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.7),
                          onChanged: (value) {
                            _storyContent = value;
                          },
                        )
                      : Text(
                          _storyContent,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.7),
                        ),
                ),

                SizedBox(height: 3.h),

                // Story Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareStory,
                        icon: CustomIconWidget(
                          iconName: 'share',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        label: const Text('Share'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _exportStory('pdf'),
                        icon: CustomIconWidget(
                          iconName: 'file_download',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        label: const Text('Export'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createNewStoryVersion,
                        icon: CustomIconWidget(
                          iconName: 'refresh',
                          color: Colors.white,
                          size: 4.w,
                        ),
                        label: const Text('Regenerate'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Related Stories
                if (_relatedStories.isNotEmpty) ...[
                  Text(
                    'Related Stories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 25.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _relatedStories.length,
                      itemBuilder: (context, index) {
                        final story = _relatedStories[index];
                        return Container(
                          width: 45.w,
                          margin: EdgeInsets.only(right: 3.w),
                          child: GestureDetector(
                            onTap: () => _onRelatedStoryTap(story),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.lightTheme.dividerColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: CustomIconWidget(
                                        iconName: 'auto_stories',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 8.w,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          story['title'] ?? 'Untitled',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          story['genre'] ?? 'Unknown',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.primary,
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
                    ),
                  ),
                ],

                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesContent() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Add Note Section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'note_add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Add a Note',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'What did you think about this story?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.all(3.w),
                  ),
                  maxLines: 3,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _addComment(value.trim());
                    }
                  },
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle add note
                      },
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: Colors.white,
                        size: 4.w,
                      ),
                      label: const Text('Add Note'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Notes List
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'notes',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                          size: 15.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No notes yet',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Add your thoughts about this story',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'person',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 4.w,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'You',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                Text(
                                  _formatDate(comment['timestamp']),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              comment['content'],
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    try {
      await AuthService.instance.signOut();
      // Navigation is handled by auth state listener
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $error')),
      );
    }
  }
}