import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _contentController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonOpacity;
  late Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animation — fast, punchy
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Content animation — staggered after logo
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo scale — bounces in
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Logo opacity
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Glow pulse behind logo
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Map dots fade in
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // Tagline slides up
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Buttons slide up after tagline
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _contentController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background map dot pattern
          AnimatedBuilder(
            animation: _dotsOpacity,
            builder: (context, _) => Opacity(
              opacity: _dotsOpacity.value * 0.35,
              child: const _MapDotPattern(),
            ),
          ),

          // Green radial glow
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (context, _) => Opacity(
              opacity: _glowOpacity.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.2),
                    radius: 0.8,
                    colors: [
                      Color(0x1A00C853),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo + Brand
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, _) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: const _LogoBlock(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: const _TaglineBlock(),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Buttons
                  SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _buttonOpacity,
                      child: _ButtonBlock(
                        onGetStarted: () =>
                            Navigator.pushNamed(context, AppRoutes.onboarding),
                        onSignIn: () =>
                            Navigator.pushNamed(context, AppRoutes.signIn),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOGO BLOCK
// ─────────────────────────────────────────────
class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: .circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.black,
            size: 40,
          ),
        ),

        const SizedBox(height: 20),

        // App name
        Text('SafeNaija', style: AppTextStyles.displayLarge),

        const SizedBox(height: 6),

        // Label
        Text(
          'SAFETY INTELLIGENCE',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.green,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TAGLINE BLOCK
// ─────────────────────────────────────────────
class _TaglineBlock extends StatelessWidget {
  const _TaglineBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Know before you go.',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Real-time safety alerts powered\nby your community. For every Nigerian.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 28),

        // Live stat chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatChip(label: '36 States', icon: Icons.map_outlined),
            const SizedBox(width: 10),
            _StatChip(label: 'Real-time', icon: Icons.bolt_rounded),
            const SizedBox(width: 10),
            _StatChip(label: 'Free', icon: Icons.favorite_rounded),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.green),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUTTON BLOCK
// ─────────────────────────────────────────────
class _ButtonBlock extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const _ButtonBlock({
    required this.onGetStarted,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary CTA
        ElevatedButton(
          onPressed: onGetStarted,
          child: Text(
            'Get Started',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.black),
          ),
        ),

        const SizedBox(height: 14),

        // Sign in link
        GestureDetector(
          onTap: onSignIn,
          child: RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: AppTextStyles.bodySmall,
              children: [
                TextSpan(
                  text: 'Sign In',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MAP DOT PATTERN BACKGROUND
// ─────────────────────────────────────────────
class _MapDotPattern extends StatelessWidget {
  const _MapDotPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPatternPainter(),
      size: Size.infinite,
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;

    const spacing = 22.0;
    const radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}