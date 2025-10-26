import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _particleAnimation;

  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _particleAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _taglineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleAnimationController,
      curve: Curves.linear,
    ));
  }

  void _startSplashSequence() async {
    // Start logo animation
    _logoAnimationController.forward();

    // Start particle animation with delay
    await Future.delayed(const Duration(milliseconds: 500));
    _particleAnimationController.repeat();

    // Show progress indicator after logo animation
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _showProgress = true;
      });
    }

    // Check connectivity and initialize app
    await _initializeApp();

    // Navigate to appropriate screen
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate app initialization
      await Future.delayed(const Duration(milliseconds: 1000));

      // In a real app, you would:
      // - Check user authentication status
      // - Initialize services
      // - Load essential data
      // - Check for updates
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('App initialization error: $e');
    }
  }

  void _navigateToNextScreen() {
    // Check if user is first-time user or returning user
    // Use auth state (signed in) to determine navigation so both branches are reachable
    final isFirstTime = !AuthService.instance.isSignedIn;

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.journalHomeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.gradientStart,
              AppTheme.gradientEnd,
              AppTheme.primaryLight,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated particles background
              _buildParticlesBackground(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),

                    // Animated logo
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Container(
                              width: 25.w,
                              height: 25.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomImageWidget(
                                  imageUrl: 'assets/images/img_app_logo.svg',
                                  width: 15.w,
                                  height: 15.w,
                                  fit: BoxFit.contain,
                                  semanticLabel:
                                      'StoryWeaver app logo featuring a quill pen with flowing ink design',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 4.h),

                    // App name
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoFadeAnimation.value,
                          child: Text(
                            'Joyce\'s.ink',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Tagline
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _taglineAnimation.value,
                          child: Text(
                            'Transform Your Thoughts Into Stories',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    // Loading indicator
                    AnimatedOpacity(
                      opacity: _showProgress ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 8.w,
                            height: 8.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Preparing your stories...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Version number
                    Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticlesBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final double animationOffset = (index * 0.1) % 1.0;
            final double currentAnimation =
                (_particleAnimation.value + animationOffset) % 1.0;

            return Positioned(
              left: (index * 7.0 + 10) % 100.0,
              top: 10.0 + (currentAnimation * 80.0),
              child: Opacity(
                opacity: 0.6 * (1.0 - currentAnimation),
                child: Container(
                  width: 2 + (index % 3),
                  height: 2 + (index % 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}