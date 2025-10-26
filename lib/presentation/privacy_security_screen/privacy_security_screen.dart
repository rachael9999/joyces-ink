import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../privacy_security_screen/widgets/data_privacy_widget.dart';
import '../privacy_security_screen/widgets/biometric_auth_widget.dart';
import '../privacy_security_screen/widgets/app_lock_widget.dart';
import '../privacy_security_screen/widgets/third_party_integrations_widget.dart';
import '../privacy_security_screen/widgets/data_retention_widget.dart';
import '../privacy_security_screen/widgets/privacy_dashboard_widget.dart';
import '../../core/app_export.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // Data Privacy Settings
  bool _analyticsSharing = false;
  bool _crashReporting = true;
  bool _usageStatistics = false;
  String _privacyLevel = 'balanced';

  // Biometric Authentication
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String _biometricType = 'none';

  // App Lock Settings
  bool _appLockEnabled = false;
  String _lockTimeout = 'immediate';
  bool _hideContentInSwitcher = true;

  // Location Services
  bool _locationEnabled = false;

  // Contact Permissions
  bool _contactsEnabled = false;

  // Marketing Communications
  bool _emailNewsletter = true;
  bool _productUpdates = true;
  bool _promotionalContent = false;

  // Data Retention
  String _retentionPeriod = '30';

  // Cloud Sync Privacy
  bool _cloudSyncEnabled = true;
  Map<String, bool> _syncPermissions = {
    'journalEntries': true,
    'preferences': true,
    'generatedStories': false,
    'analytics': false,
  };

  // Third-party integrations
  final List<Map<String, dynamic>> _thirdPartyServices = [
    {
      'name': 'Google Drive',
      'description': 'Cloud storage for backups',
      'connected': false,
      'dataShared': ['Journal entries', 'User preferences'],
      'icon': Icons.cloud,
    },
    {
      'name': 'AI Story Generator',
      'description': 'Enhanced story generation',
      'connected': true,
      'dataShared': ['Writing prompts', 'Generated content'],
      'icon': Icons.auto_awesome,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometricAvailability();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _analyticsSharing = prefs.getBool('analytics_sharing') ?? false;
      _crashReporting = prefs.getBool('crash_reporting') ?? true;
      _usageStatistics = prefs.getBool('usage_statistics') ?? false;
      _privacyLevel = prefs.getString('privacy_level') ?? 'balanced';

      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _lockTimeout = prefs.getString('lock_timeout') ?? 'immediate';
      _hideContentInSwitcher = prefs.getBool('hide_content_switcher') ?? true;

      _locationEnabled = prefs.getBool('location_enabled') ?? false;
      _contactsEnabled = prefs.getBool('contacts_enabled') ?? false;

      _emailNewsletter = prefs.getBool('email_newsletter') ?? true;
      _productUpdates = prefs.getBool('product_updates') ?? true;
      _promotionalContent = prefs.getBool('promotional_content') ?? false;

      _retentionPeriod = prefs.getString('retention_period') ?? '30';
      _cloudSyncEnabled = prefs.getBool('cloud_sync_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('analytics_sharing', _analyticsSharing);
    await prefs.setBool('crash_reporting', _crashReporting);
    await prefs.setBool('usage_statistics', _usageStatistics);
    await prefs.setString('privacy_level', _privacyLevel);

    await prefs.setBool('biometric_enabled', _biometricEnabled);
    await prefs.setBool('app_lock_enabled', _appLockEnabled);
    await prefs.setString('lock_timeout', _lockTimeout);
    await prefs.setBool('hide_content_switcher', _hideContentInSwitcher);

    await prefs.setBool('location_enabled', _locationEnabled);
    await prefs.setBool('contacts_enabled', _contactsEnabled);

    await prefs.setBool('email_newsletter', _emailNewsletter);
    await prefs.setBool('product_updates', _productUpdates);
    await prefs.setBool('promotional_content', _promotionalContent);

    await prefs.setString('retention_period', _retentionPeriod);
    await prefs.setBool('cloud_sync_enabled', _cloudSyncEnabled);
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Simulate biometric availability check
      if (!kIsWeb) {
        setState(() {
          _biometricAvailable = true;
          _biometricType = 'fingerprint'; // Could be face, fingerprint, etc.
        });
      }
    } catch (e) {
      setState(() {
        _biometricAvailable = false;
        _biometricType = 'none';
      });
    }
  }

  Future<void> _authenticateAndSave() async {
    try {
      // Simulate authentication requirement for security changes
      await _saveSettings();

      Fluttertoast.showToast(
        msg: "Security settings updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update settings: Authentication required",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Joyce\'s Ink Privacy Policy\n\n'
            'Your privacy is important to us. This policy explains how we collect, use, and protect your personal information.\n\n'
            '1. Data Collection: We only collect data necessary to provide our services.\n'
            '2. Data Usage: Your data is used to enhance your writing experience.\n'
            '3. Data Protection: We implement industry-standard security measures.\n'
            '4. Data Sharing: We never sell your personal data to third parties.\n\n'
            'For the complete privacy policy, visit our website.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Open full privacy policy
              Fluttertoast.showToast(
                msg: "Opening full privacy policy...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: const Text('Read Full Policy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy & Security',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.policy_outlined,
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            ),
            onPressed: _showPrivacyPolicy,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Privacy Section
            DataPrivacyWidget(
              privacyLevel: _privacyLevel,
              analyticsSharing: _analyticsSharing,
              crashReporting: _crashReporting,
              usageStatistics: _usageStatistics,
              onPrivacyLevelChanged: (value) {
                setState(() {
                  _privacyLevel = value;
                  // Update related settings based on privacy level
                  switch (value) {
                    case 'minimal':
                      _analyticsSharing = false;
                      _usageStatistics = false;
                      _crashReporting = false;
                      break;
                    case 'balanced':
                      _analyticsSharing = false;
                      _usageStatistics = false;
                      _crashReporting = true;
                      break;
                    case 'enhanced':
                      _analyticsSharing = true;
                      _usageStatistics = true;
                      _crashReporting = true;
                      break;
                  }
                });
                _authenticateAndSave();
              },
              onAnalyticsChanged: (value) {
                setState(() => _analyticsSharing = value);
                _authenticateAndSave();
              },
              onCrashReportingChanged: (value) {
                setState(() => _crashReporting = value);
                _authenticateAndSave();
              },
              onUsageStatisticsChanged: (value) {
                setState(() => _usageStatistics = value);
                _authenticateAndSave();
              },
            ),

            SizedBox(height: 3.h),

            // Biometric Authentication
            BiometricAuthWidget(
              biometricEnabled: _biometricEnabled,
              biometricAvailable: _biometricAvailable,
              biometricType: _biometricType,
              onBiometricToggle: (value) async {
                if (value && _biometricAvailable) {
                  // Simulate biometric setup
                  setState(() => _biometricEnabled = value);
                  await _authenticateAndSave();
                } else {
                  setState(() => _biometricEnabled = false);
                  await _authenticateAndSave();
                }
              },
            ),

            SizedBox(height: 3.h),

            // App Lock Settings
            AppLockWidget(
              appLockEnabled: _appLockEnabled,
              lockTimeout: _lockTimeout,
              hideContentInSwitcher: _hideContentInSwitcher,
              onAppLockToggle: (value) {
                setState(() => _appLockEnabled = value);
                _authenticateAndSave();
              },
              onTimeoutChanged: (value) {
                setState(() => _lockTimeout = value);
                _authenticateAndSave();
              },
              onHideContentToggle: (value) {
                setState(() => _hideContentInSwitcher = value);
                _authenticateAndSave();
              },
            ),

            SizedBox(height: 3.h),

            // Permissions Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Permissions',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Location Services
                    _buildPermissionTile(
                      icon: Icons.location_on,
                      title: 'Location Services',
                      description:
                          'Enable GPS-based features and location tagging',
                      value: _locationEnabled,
                      onChanged: (value) {
                        setState(() => _locationEnabled = value);
                        _authenticateAndSave();
                      },
                      isDark: isDark,
                    ),

                    SizedBox(height: 2.h),

                    // Contact Permissions
                    _buildPermissionTile(
                      icon: Icons.contacts,
                      title: 'Contact Access',
                      description: 'Access contacts for sharing features',
                      value: _contactsEnabled,
                      onChanged: (value) {
                        setState(() => _contactsEnabled = value);
                        _authenticateAndSave();
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Third-party Integrations
            ThirdPartyIntegrationsWidget(
              thirdPartyServices: _thirdPartyServices,
              onServiceToggle: (index, connected) {
                setState(() {
                  _thirdPartyServices[index]['connected'] = connected;
                });
                _authenticateAndSave();
              },
            ),

            SizedBox(height: 3.h),

            // Marketing Communications
            Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketing Communications',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _buildPermissionTile(
                      icon: Icons.email,
                      title: 'Email Newsletter',
                      description:
                          'Receive weekly writing tips and inspiration',
                      value: _emailNewsletter,
                      onChanged: (value) {
                        setState(() => _emailNewsletter = value);
                        _saveSettings();
                      },
                      isDark: isDark,
                    ),
                    SizedBox(height: 2.h),
                    _buildPermissionTile(
                      icon: Icons.system_update,
                      title: 'Product Updates',
                      description:
                          'Get notified about new features and improvements',
                      value: _productUpdates,
                      onChanged: (value) {
                        setState(() => _productUpdates = value);
                        _saveSettings();
                      },
                      isDark: isDark,
                    ),
                    SizedBox(height: 2.h),
                    _buildPermissionTile(
                      icon: Icons.local_offer,
                      title: 'Promotional Content',
                      description:
                          'Receive special offers and premium upgrades',
                      value: _promotionalContent,
                      onChanged: (value) {
                        setState(() => _promotionalContent = value);
                        _saveSettings();
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Data Retention
            DataRetentionWidget(
              retentionPeriod: _retentionPeriod,
              onRetentionChanged: (value) {
                setState(() => _retentionPeriod = value);
                _authenticateAndSave();
              },
            ),

            SizedBox(height: 3.h),

            // Privacy Dashboard
            PrivacyDashboardWidget(),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
