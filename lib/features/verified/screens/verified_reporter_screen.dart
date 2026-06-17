import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class VerifiedReporterScreen extends StatefulWidget {
  const VerifiedReporterScreen({super.key});

  @override
  State<VerifiedReporterScreen> createState() =>
      _VerifiedReporterScreenState();
}

class _VerifiedReporterScreenState extends State<VerifiedReporterScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;

  // Mock — already verified
  final bool _isVerified = true;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.elasticOut,
      ),
    );

    _entryController.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _badgeController.forward(),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _apply() async {
    setState(() => _isApplying = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isApplying = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Application submitted. We\'ll review within 48 hours.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _VerifiedHeader(
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                // Hero badge
                SliverToBoxAdapter(
                  child: _BadgeHero(
                    isVerified: _isVerified,
                    badgeScale: _badgeScale,
                    badgeController: _badgeController,
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isVerified) ...[
                          // Verified stats
                          _VerifiedStats(),
                          const SizedBox(height: 24),
                          // Benefits section
                          _SectionLabel(label: 'Your Benefits'),
                          const SizedBox(height: 12),
                          _BenefitsCard(isVerified: true),
                          const SizedBox(height: 24),
                          // Activity
                          _SectionLabel(label: 'Reporter Activity'),
                          const SizedBox(height: 12),
                          _ActivityCard(),
                          const SizedBox(height: 24),
                          // Guidelines
                          _SectionLabel(label: 'Reporting Guidelines'),
                          const SizedBox(height: 12),
                          _GuidelinesCard(),
                        ] else ...[
                          // Not verified — apply CTA
                          _SectionLabel(label: 'What You Get'),
                          const SizedBox(height: 12),
                          _BenefitsCard(isVerified: false),
                          const SizedBox(height: 24),
                          _SectionLabel(label: 'Requirements'),
                          const SizedBox(height: 12),
                          _RequirementsCard(),
                          const SizedBox(height: 28),
                          _ApplyButton(
                            isApplying: _isApplying,
                            onTap: _apply,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _VerifiedHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _VerifiedHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text('Verified Reporter', style: AppTextStyles.headingLarge),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BADGE HERO
// ─────────────────────────────────────────────
class _BadgeHero extends StatelessWidget {
  final bool isVerified;
  final Animation<double> badgeScale;
  final AnimationController badgeController;

  const _BadgeHero({
    required this.isVerified,
    required this.badgeScale,
    required this.badgeController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isVerified
                ? AppColors.green.withOpacity(0.1)
                : AppColors.textMuted.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Badge icon
          ScaleTransition(
            scale: badgeScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVerified
                          ? AppColors.green.withOpacity(0.3)
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isVerified
                        ? AppColors.green
                        : AppColors.surface2,
                    shape: BoxShape.circle,
                    boxShadow: isVerified
                        ? [
                            BoxShadow(
                              color: AppColors.green.withOpacity(0.35),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    isVerified
                        ? Icons.verified_rounded
                        : Icons.shield_outlined,
                    color: isVerified ? Colors.black : AppColors.textMuted,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isVerified ? 'Verified Reporter' : 'Community Member',
            style: AppTextStyles.headingLarge,
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isVerified ? AppColors.safeBg : AppColors.surface2,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isVerified
                    ? AppColors.green.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Text(
              isVerified ? '✓ Badge Active · Since Jan 2025' : 'Not yet verified',
              style: AppTextStyles.caption.copyWith(
                color: isVerified ? AppColors.green : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VERIFIED STATS
// ─────────────────────────────────────────────
class _VerifiedStats extends StatelessWidget {
  const _VerifiedStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(value: '24', label: 'Reports', color: AppColors.green),
        const SizedBox(width: 8),
        _StatBox(value: '96%', label: 'Accuracy', color: AppColors.warning),
        const SizedBox(width: 8),
        _StatBox(value: '312', label: 'Confirmed', color: Color(0xFF5E9BF0)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BENEFITS CARD
// ─────────────────────────────────────────────
class _BenefitsCard extends StatelessWidget {
  final bool isVerified;

  const _BenefitsCard({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      _Benefit(
        icon: Icons.verified_rounded,
        label: 'Verified badge on all reports',
        color: AppColors.green,
      ),
      _Benefit(
        icon: Icons.trending_up_rounded,
        label: 'Reports shown with higher priority',
        color: AppColors.warning,
      ),
      _Benefit(
        icon: Icons.people_rounded,
        label: 'Access to verified reporter community',
        color: Color(0xFF5E9BF0),
      ),
      _Benefit(
        icon: Icons.analytics_outlined,
        label: 'Advanced reporting analytics',
        color: AppColors.green,
      ),
      _Benefit(
        icon: Icons.support_agent_rounded,
        label: 'Priority support from SafeNaija team',
        color: AppColors.warning,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: benefits.asMap().entries.map((entry) {
          final index = entry.key;
          final benefit = entry.value;
          final isLast = index == benefits.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: benefit.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: benefit.color.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        benefit.icon,
                        color: benefit.color,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isVerified)
                      const Icon(
                        Icons.check_rounded,
                        color: AppColors.green,
                        size: 16,
                      ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  color: AppColors.border,
                  height: 1,
                  indent: 44,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTIVITY CARD
// ─────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(
        title: 'Armed Robbery — Oshodi',
        time: '2 days ago',
        confirmed: 47,
        status: 'Verified',
        statusColor: AppColors.green,
      ),
      _Activity(
        title: 'Dangerous Road — Mile 2',
        time: '5 days ago',
        confirmed: 12,
        status: 'Verified',
        statusColor: AppColors.green,
      ),
      _Activity(
        title: 'Suspicious Activity — Surulere',
        time: '1 week ago',
        confirmed: 3,
        status: 'Under Review',
        statusColor: AppColors.warning,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final isLast = index == activities.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                activity.time,
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '· ${activity.confirmed} confirmed',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: activity.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: activity.statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        activity.status,
                        style: AppTextStyles.caption.copyWith(
                          color: activity.statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  color: AppColors.border,
                  height: 1,
                  indent: 14,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GUIDELINES CARD
// ─────────────────────────────────────────────
class _GuidelinesCard extends StatelessWidget {
  const _GuidelinesCard();

  @override
  Widget build(BuildContext context) {
    final guidelines = [
      'Only report what you personally witnessed or have strong evidence of',
      'Include specific location, time, and details in every report',
      'Do not report rumours — verify before submitting',
      'False reports will result in badge removal and account suspension',
      'Your safety comes first — never put yourself at risk to report',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: guidelines.asMap().entries.map((entry) {
          final index = entry.key;
          final guideline = entry.value;
          final isLast = index == guidelines.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: AppColors.safeBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.green,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        guideline,
                        style: AppTextStyles.bodySmall.copyWith(
                          height: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(color: AppColors.border, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REQUIREMENTS CARD
// ─────────────────────────────────────────────
class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard();

  @override
  Widget build(BuildContext context) {
    final requirements = [
      _Requirement(
        icon: Icons.campaign_rounded,
        label: 'At least 5 submitted reports',
        met: true,
      ),
      _Requirement(
        icon: Icons.check_circle_outline_rounded,
        label: 'Minimum 70% report accuracy rate',
        met: true,
      ),
      _Requirement(
        icon: Icons.calendar_today_rounded,
        label: 'Account at least 30 days old',
        met: true,
      ),
      _Requirement(
        icon: Icons.phone_android_rounded,
        label: 'Verified phone number',
        met: false,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: requirements.asMap().entries.map((entry) {
          final index = entry.key;
          final req = entry.value;
          final isLast = index == requirements.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: req.met
                            ? AppColors.safeBg
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: req.met
                              ? AppColors.green.withOpacity(0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        req.icon,
                        color: req.met
                            ? AppColors.green
                            : AppColors.textMuted,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        req.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: req.met
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Icon(
                      req.met
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: req.met
                          ? AppColors.green
                          : AppColors.border,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  color: AppColors.border,
                  height: 1,
                  indent: 60,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APPLY BUTTON
// ─────────────────────────────────────────────
class _ApplyButton extends StatelessWidget {
  final bool isApplying;
  final VoidCallback onTap;

  const _ApplyButton({
    required this.isApplying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isApplying ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isApplying
              ? AppColors.green.withOpacity(0.6)
              : AppColors.green,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isApplying
              ? []
              : [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isApplying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Apply for Verification',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.black,
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
// DATA MODELS
// ─────────────────────────────────────────────
class _Benefit {
  final IconData icon;
  final String label;
  final Color color;

  const _Benefit({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _Activity {
  final String title;
  final String time;
  final int confirmed;
  final String status;
  final Color statusColor;

  const _Activity({
    required this.title,
    required this.time,
    required this.confirmed,
    required this.status,
    required this.statusColor,
  });
}

class _Requirement {
  final IconData icon;
  final String label;
  final bool met;

  const _Requirement({
    required this.icon,
    required this.label,
    required this.met,
  });
}