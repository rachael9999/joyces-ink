import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // User data (loaded from Supabase)
  Map<String, dynamic> _userData = {
    'name': 'Loading…',
    'email': '',
    'memberSince': null,
    'avatar': null,
    'bio': null,
    'writingStreak': 0,
    'totalEntries': 0,
    'storiesGenerated': 0,
    'favoriteGenres': <String>[],
    'dailyGoal': 300,
    'currentStreak': 0,
    'longestStreak': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _initializeAnimations();
    _loadUser();
  }
  Future<void> _loadUser() async {
    try {
      final user = AuthService.instance.currentUser;
      final profile = await AuthService.instance.getUserProfile() ?? {};

      setState(() {
        _userData['name'] = (profile['full_name'] ?? user?.email ?? 'User') as String;
        _userData['email'] = user?.email ?? '';
        _userData['avatar'] = profile['avatar_url'];
        _userData['bio'] = profile['bio'];
        // Optional: If your user profile table stores created_at
        _userData['memberSince'] = profile['created_at'] != null
            ? DateTime.tryParse(profile['created_at'])
            : null;
      });
    } catch (e) {
      // Keep defaults on failure
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;

      final user = AuthService.instance.currentUser;
      if (user == null) return;

      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final path = 'public/${user.id}.${ext.isEmpty ? 'jpg' : ext}';
      final storage = SupabaseService.instance.client.storage.from('avatars');

      // Attempt upload; overwrite any existing
      await storage.uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
      final publicUrl = storage.getPublicUrl(path);

      await AuthService.instance.updateUserProfile(avatarUrl: publicUrl);

      setState(() {
        _userData['avatar'] = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
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
                    onTap: () async {
                      try {
                        await AuthService.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.loginScreen,
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sign out failed: ' +
                                  e.toString().replaceFirst('Exception: ', ''),
                            ),
                            backgroundColor: Colors.red.shade600,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'logout',
                        color: AppTheme.lightTheme.colorScheme.error,
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
                            onAvatarTap: _pickAndUploadAvatar,
                          ),

                          SizedBox(height: 3.h),

                          // Profile Statistics
                          ProfileStatsWidget(userData: _userData),

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
                                'Password',
                                '••••••••',
                                'lock',
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

                          // Removed Danger Zone (Delete Account) as requested

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

  // Removed export dialog as requested

  

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

  
}
