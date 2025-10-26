import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';
import './widgets/permission_request_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  bool _microphonePermissionGranted = false;
  bool _notificationPermissionGranted = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Capture Your Soul's Whispers",
      "description":
          "Transform fleeting thoughts into eternal stories. Let your voice flow through time as you weave memories, dreams, and emotions into a tapestry of personal narrative.",
      "imageUrl":
          "https://images.unsplash.com/photo-1591088761584-d3f8540fc587",
      "semanticLabel":
          "Person writing in a journal with a pen, surrounded by coffee cup and plants on a wooden desk",
    },
    {
      "title": "Alchemy of Words & Wonder",
      "description":
          "Watch the magic unfold as AI breathes life into your thoughts, crafting enchanting tales across infinite genres - from mystical adventures to tender love stories that dance with your heart.",
      "imageUrl":
          "https://images.unsplash.com/photo-1689467902804-8d4053084626",
      "semanticLabel":
          "Stack of colorful books with magical sparkles and light effects floating above them",
    },
    {
      "title": "Share Your Creative Legacy",
      "description":
          "Your stories deserve to flourish in the world. Export as beautiful PDFs, share across digital realms, or treasure them in your private sanctuary of creativity.",
      "imageUrl":
          "https://images.unsplash.com/photo-1681454017264-34d4348375a4",
      "semanticLabel":
          "Person holding a smartphone showing a story being shared, with social media icons floating around",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _checkPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    final notificationStatus = await Permission.notification.status;

    setState(() {
      _microphonePermissionGranted = microphoneStatus.isGranted;
      _notificationPermissionGranted = notificationStatus.isGranted;
    });
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _microphonePermissionGranted = status.isGranted;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationPermissionGranted = status.isGranted;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
  }

  Widget _buildPermissionPage() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
              AppTheme.lightTheme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with more artistic spacing
            Container(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Column(
                children: [
                  Text(
                    'Awaken Your Creative Powers',
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Grant these gentle permissions to unlock the full symphony of storytelling possibilities within joycesink',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Permission requests with enhanced shadows
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight.withValues(alpha: 0.15),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: AppTheme.shadowLight.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PermissionRequestWidget(
                            iconName: 'mic',
                            title: 'Voice of Inspiration',
                            description:
                                'Capture the rhythm of your thoughts through voice, transforming spoken dreams into written treasures',
                            isGranted: _microphonePermissionGranted,
                            onTap: _requestMicrophonePermission,
                          ),
                          SizedBox(height: 4.h),
                          PermissionRequestWidget(
                            iconName: 'notifications',
                            title: 'Gentle Creative Nudges',
                            description:
                                'Receive whispered reminders to nurture your daily writing ritual and keep your creative flame burning bright',
                            isGranted: _notificationPermissionGranted,
                            onTap: _requestNotificationPermission,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(6.w),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 6.w,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Your creative sanctuary is protected. All permissions can be gracefully adjusted in your device settings whenever your heart desires.',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Get Started button with enhanced styling
            Container(
              margin: EdgeInsets.only(top: 4.h),
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: _getStarted,
                style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(8),
                  shadowColor: WidgetStateProperty.all(
                    AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Text(
                  'Begin My Story',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length + 1, // +1 for permission page
                itemBuilder: (context, index) {
                  if (index < _onboardingData.length) {
                    final data = _onboardingData[index];
                    return OnboardingPageWidget(
                      title: data["title"] as String,
                      description: data["description"] as String,
                      imageUrl: data["imageUrl"] as String,
                      semanticLabel: data["semanticLabel"] as String,
                      onNext: _nextPage,
                      onSkip: _skipOnboarding,
                    );
                  } else {
                    // Permission page
                    return _buildPermissionPage();
                  }
                },
              ),
            ),

            // Page indicator
            if (_currentPage < _onboardingData.length)
              Container(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: PageIndicatorWidget(
                  currentPage: _currentPage,
                  totalPages: _onboardingData.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
