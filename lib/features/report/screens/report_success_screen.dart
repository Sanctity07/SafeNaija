import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class ReportSuccessScreen extends StatefulWidget {
  const ReportSuccessScreen({super.key});

  @override
  State<ReportSuccessScreen> createState() => _ReportSuccessScreenState();
}

class _ReportSuccessScreenState extends State<ReportSuccessScreen>
    with TickerProviderStateMixin {
  // Check animation
  late AnimationController _checkController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  // Ring pulse
  late AnimationController _ringController;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  // Content slide
  late AnimationController _contentController;
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentFade;

  // Particle burst
  late AnimationController _particleController;

  // Buttons
  late AnimationController _buttonController;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    // Check bounce
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: Curves.elasticOut,
      ),
    );

    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Ring pulse — loops
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _ringScale = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _ringOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    // Particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Content slide
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    // Buttons
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _ringController.repeat();

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _ringController.dispose();
    _particleController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 0.8,
                colors: [
                  Color(0x1200C853),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Check icon with rings + particles
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring pulse
                        AnimatedBuilder(
                          animation: _ringController,
                          builder: (context, _) => Transform.scale(
                            scale: _ringScale.value,
                            child: Opacity(
                              opacity: _ringOpacity.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.green,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Particle burst
                        AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, _) => CustomPaint(
                            size: const Size(200, 200),
                            painter: _ParticlePainter(
                              progress: _particleController.value,
                            ),
                          ),
                        ),

                        // Green circle + check
                        AnimatedBuilder(
                          animation: _checkController,
                          builder: (context, _) => Transform.scale(
                            scale: _checkScale.value,
                            child: Opacity(
                              opacity: _checkOpacity.value,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.green.withOpacity(0.45),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.black,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Content
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: Column(
                        children: [
                          Text(
                            'Report Submitted.',
                            style: AppTextStyles.displayMedium,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Your community has been alerted.\nStay safe and stay vigilant.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textMuted,
                              height: 1.65,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Stats row
                          _StatsRow(),

                          const SizedBox(height: 32),

                          // Report summary card
                          _SummaryCard(),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _buttonFade,
                      child: _ActionButtons(),
                    ),
                  ),

                  const SizedBox(height: 32),
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
// STATS ROW
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.notifications_active_rounded,
          label: 'Alerting',
          value: '~340',
          color: AppColors.green,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.location_on_rounded,
          label: 'Radius',
          value: '5km',
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.shield_rounded,
          label: 'Status',
          value: 'Live',
          color: AppColors.danger,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withOpacity(0.7),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.warning_rounded,
            label: 'Type',
            value: 'Armed Robbery',
            valueColor: AppColors.danger,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: 'Oshodi, Lagos',
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.access_time_rounded,
            label: 'Submitted',
            value: 'Just now',
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.visibility_off_outlined,
            label: 'Identity',
            value: 'Anonymous',
            valueColor: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // View on map
        GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          ),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map_rounded,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'View on Map',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Report another
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.report,
          ),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Report Another Incident',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textMuted,
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
// PARTICLE PAINTER
// ─────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;

  const _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42);

    for (int i = 0; i < 16; i++) {
      final angle = (i / 16) * 2 * math.pi;
      final speed = 50.0 + random.nextDouble() * 30;
      final distance = speed * progress;

      final offset = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final radius = (2.0 + random.nextDouble() * 2) * (1 - progress * 0.5);

      // Alternate green and white particles
      final color = i % 3 == 0
          ? AppColors.green.withOpacity(opacity)
          : i % 3 == 1
              ? Colors.white.withOpacity(opacity * 0.6)
              : AppColors.green.withOpacity(opacity * 0.4);

      canvas.drawCircle(
        offset,
        radius,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}  