import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../theme/app_colors.dart';
import '../widgets/dev_overlay.dart';

/// 3-slide onboarding shown on first launch.
/// Persists completion in Hive so it never shows again.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> shouldShow() async {
    final box = Hive.box('settings');
    return box.get('onboarding_complete', defaultValue: false) == false;
  }

  static void markComplete() {
    Hive.box('settings').put('onboarding_complete', true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    DevOverlay.currentFilePath = 'lib/screens/onboarding_screen.dart';
  }

  static const _slides = [
    _SlideData(
      icon: '🎰',
      title: 'Spin the Wheel',
      body: 'Tap SPIN and let the wheel choose a challenge for you. Each task belongs to a category with its own flavor.',
      color: AppColors.accent,
    ),
    _SlideData(
      icon: '⚡',
      title: 'Accept or Skip',
      body: 'Accept to earn points — or skip and lose them. The choice is always yours, but choose wisely...',
      color: Color(0xFFFFD700),
    ),
    _SlideData(
      icon: '🏆',
      title: 'Score & Switch',
      body: 'Earn points for every task you complete. After each turn, play passes to the other player. First to bragging rights wins.',
      color: Color(0xFFFF6B6B),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    OnboardingScreen.markComplete();
    Navigator.of(context).pop();
  }

  void _skip() {
    _finish();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button (top right)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Text(
                            slide.icon,
                            style: const TextStyle(fontSize: 72),
                          ),
                          const SizedBox(height: 32),

                          // Title
                          Text(
                            slide.title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Body
                          Text(
                            slide.body,
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? _slides[i].color
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _nextPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _slides[_currentPage].color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
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
    );
  }
}

class _SlideData {
  final String icon;
  final String title;
  final String body;
  final Color color;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}
