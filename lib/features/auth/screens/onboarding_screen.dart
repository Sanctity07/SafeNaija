import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _contentController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.map_rounded,
      tag: 'LIVE MAP',
      title: 'See danger\nbefore it sees you.',
      body:
          'Real-time incident map showing active threats, danger zones, and safe routes across all 36 states.',
      color: Color(0xFF00C853),
    ),
    _OnboardingData(
      icon: Icons.campaign_rounded,
      tag: 'COMMUNITY REPORTS',
      title: 'Your people\nkeep you safe.',
      body:
          'Nigerians report what they see — verified by the community. No government filter. No delay.',
      color: Color(0xFFFF9500),
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      tag: 'INSTANT ALERTS',
      title: 'Know the moment\nsomething happens.',
      body:
          'Get push alerts for incidents near you, your family, and places you care about — before it hits WhatsApp.',
      color: Color(0xFFFF3B30),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.signUp);
    }
  }

  void _skip() {
    Navigator.pushNamed(context, AppRoutes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Animated background glow — color shifts per page
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.1),
                radius: 0.75,
                colors: [
                  page.color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => _PageDot(
                            isActive: i == _currentPage,
                            color: page.color,
                          ),
                        ),
                      ),

                      // Skip button
                      GestureDetector(
                        onTap: _skip,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        slideAnimation: _slideAnimation,
                        fadeAnimation: _fadeAnimation,
                      );
                    },
                  ),
                ),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Column(
                    children: [
                      // Next / Get Started button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: page.color,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: page.color.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? 'Create Account' : 'Next',
                                style: AppTextStyles.labelLarge
                                    .copyWith(color: Colors.black),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.arrow_forward_rounded
                                    : Icons.chevron_right_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign in link
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.signIn),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: AppTextStyles.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: page.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SINGLE PAGE CONTENT
// ─────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const _OnboardingPage({
    required this.data,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: data.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  data.icon,
                  color: data.color,
                  size: 34,
                ),
              ),

              const SizedBox(height: 28),

              // Tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: data.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  data.tag,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: data.color,
                    letterSpacing: 2.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                data.title,
                style: AppTextStyles.displayMedium.copyWith(height: 1.2),
              ),

              const SizedBox(height: 14),

              // Body
              Text(
                data.body,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE DOT INDICATOR
// ─────────────────────────────────────────────
class _PageDot extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageDot({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 6),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.border,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class _OnboardingData {
  final IconData icon;
  final String tag;
  final String title;
  final String body;
  final Color color;

  const _OnboardingData({
    required this.icon,
    required this.tag,
    required this.title,
    required this.body,
    required this.color,
  });
}