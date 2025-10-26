import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_stats_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/theme_selector_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _profileAnimationController;
  late Animation<double> _profileFadeAnimation;

  String _selectedTheme = 'System';
  bool _notificationsEnabled = true;
  bool _backupEnabled = true;
  bool _privacyMode = false;

  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Sarah Johnson',
    'email': 'sarah.johnson@email.com',
    'memberSince': DateTime(2023, 6, 15),
    'avatar': null,
    'bio': 'Creative Writer & Storyteller',
    'writingStreak': 7,
    'totalEntries': 24,
    'storiesGenerated': 12,
    'favoriteGenres': ['Fantasy', 'Romance', 'Adventure'],
    'dailyGoal': 300, // words
    'currentStreak': 7,
    'longestStreak': 15,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _initializeAnimations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _profileFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileAnimationController.forward();
    });
  }

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

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => _buildExportDataDialog(),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteAccountDialog(),
    );
  }

  void _showSubscriptionInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSubscriptionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Profile',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSettingsMenu,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'settings',
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
                tabs: const [
                  Tab(text: 'Journal'),
                  Tab(text: 'Stories'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),

            // Content
            Expanded(
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

                          // Profile Header
                          ProfileHeaderWidget(
                            userData: _userData,
                            onAvatarTap: _navigateToEditProfile,
                          ),

                          SizedBox(height: 3.h),

                          // Profile Statistics
                          ProfileStatsWidget(userData: _userData),

                          SizedBox(height: 3.h),

                          // Quick Actions
                          QuickActionsWidget(
                            onEditProfile: _navigateToEditProfile,
                            onWritingGoals: _navigateToWritingGoals,
                            onExportData: _exportData,
                          ),

                          SizedBox(height: 3.h),

                          // Settings Sections
                          SettingsSectionWidget(
                            title: 'Account',
                            children: [
                              _buildSettingsTile(
                                'Email',
                                _userData['email'],
                                'email',
                                () {},
                              ),
                              _buildSettingsTile(
                                'Password',
                                '••••••••',
                                'lock',
                                () {},
                              ),
                              _buildSettingsTile(
                                'Subscription',
                                'Free Plan',
                                'star',
                                _showSubscriptionInfo,
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .lightTheme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Upgrade',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
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
                                '${_userData['totalEntries']} entries, 2.4 MB',
                                'storage',
                                () {},
                              ),
                              _buildSettingsTile(
                                'About StoryWeaver',
                                'Version 1.0.0',
                                'info',
                                () {},
                              ),
                            ],
                          ),

                          SizedBox(height: 3.h),

                          // Danger Zone
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.error
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Danger Zone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(height: 2.h),
                                OutlinedButton.icon(
                                  onPressed: _deleteAccount,
                                  icon: CustomIconWidget(
                                    iconName: 'delete_forever',
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    size: 5.w,
                                  ),
                                  label: const Text('Delete Account'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        AppTheme.lightTheme.colorScheme.error,
                                    side: BorderSide(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
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
            ),
          ],
        ),
      ),
    );
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
      ),
      trailing: trailing ??
          CustomIconWidget(
            iconName: 'chevron_right',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.5),
            size: 5.w,
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            // Edit profile form would go here
            const Center(
              child: Text('Edit profile form coming soon...'),
            ),
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
            value: _userData['dailyGoal'].toDouble(),
            min: 100,
            max: 1000,
            divisions: 9,
            label: '${_userData['dailyGoal']} words',
            onChanged: (value) {
              setState(() {
                _userData['dailyGoal'] = value.round();
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

  Widget _buildExportDataDialog() {
    return AlertDialog(
      title: const Text('Export Data'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose export format:'),
          ListTile(
            title: Text('JSON'),
            subtitle: Text('Machine readable format'),
          ),
          ListTile(
            title: Text('PDF'),
            subtitle: Text('Formatted document'),
          ),
          ListTile(
            title: Text('ZIP Archive'),
            subtitle: Text('All files and media'),
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
          child: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildDeleteAccountDialog() {
    return AlertDialog(
      title: Text(
        'Delete Account',
        style: TextStyle(
          color: AppTheme.lightTheme.colorScheme.error,
        ),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            // Premium features would go here
            const Center(
              child: Text('Premium features coming soon...'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu() {
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
                  iconName: 'logout',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
