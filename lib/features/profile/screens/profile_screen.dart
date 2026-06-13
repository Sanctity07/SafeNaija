import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock user data — replaced by Firebase later
  final _user = _UserProfile(
    name: 'Lucky Amiara',
    phone: '080XXXXXXXX',
    state: 'Lagos',
    tier: UserTier.verified,
    totalReports: 24,
    confirmedReports: 312,
    joinedDate: 'January 2025',
    avatarInitials: 'LA',
  );

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

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _confirmSignOut() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SignOutSheet(
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splash,
            (route) => false,
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
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
                  child: _ProfileHeader(
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                // Hero section
                SliverToBoxAdapter(
                  child: _ProfileHero(user: _user),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: _StatsSection(user: _user),
                ),

                // Menu sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account section
                        _SectionLabel(label: 'Account'),
                        const SizedBox(height: 10),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.person_outline_rounded,
                              label: 'Edit Profile',
                              subtitle: 'Name, phone, state',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.shield_outlined,
                              label: 'Verified Reporter',
                              subtitle: 'Active · Badge earned',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.verifiedReporter,
                              ),
                              trailingWidget: _VerifiedBadge(),
                            ),
                            _MenuItem(
                              icon: Icons.lock_outline_rounded,
                              label: 'Change Password',
                              subtitle: 'Update your password',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Preferences section
                        _SectionLabel(label: 'Preferences'),
                        const SizedBox(height: 10),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.notifications_outlined,
                              label: 'Notification Settings',
                              subtitle: 'Alerts within 5km radius',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.notificationSettings,
                              ),
                            ),
                            _MenuItem(
                              icon: Icons.location_on_outlined,
                              label: 'Safe Zones',
                              subtitle: 'Home, Work, School',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.safeZones,
                              ),
                            ),
                            _MenuItem(
                              icon: Icons.language_rounded,
                              label: 'Language',
                              subtitle: 'English',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.language,
                              ),
                              trailingWidget: _LanguageTag(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Activity section
                        _SectionLabel(label: 'Activity'),
                        const SizedBox(height: 10),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.history_rounded,
                              label: 'My Reports',
                              subtitle:
                                  '${_user.totalReports} reports submitted',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Confirmations',
                              subtitle:
                                  '${_user.confirmedReports} incidents confirmed',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Support section
                        _SectionLabel(label: 'Support'),
                        const SizedBox(height: 10),
                        _MenuCard(
                          items: [
                            _MenuItem(
                              icon: Icons.help_outline_rounded,
                              label: 'Help & FAQ',
                              subtitle: 'How SafeNaija works',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.flag_outlined,
                              label: 'Report a Problem',
                              subtitle: 'App bugs or false reports',
                              onTap: () {},
                            ),
                            _MenuItem(
                              icon: Icons.info_outline_rounded,
                              label: 'About SafeNaija',
                              subtitle: 'Version 1.0.0',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sign out
                        _SignOutButton(onTap: _confirmSignOut),

                        const SizedBox(height: 12),

                        // Footer
                        Center(
                          child: Text(
                            'SafeNaija · Built for every Nigerian',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted.withOpacity(0.4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
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
class _ProfileHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ProfileHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          Text('Profile', style: AppTextStyles.headingLarge),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE HERO
// ─────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final _UserProfile user;

  const _ProfileHero({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface2,
            AppColors.green.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.green,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.avatarInitials,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.green,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              // Online indicator
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface2,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.headingMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${user.state} State',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _TierBadge(tier: user.tier),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.textMuted,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TIER BADGE
// ─────────────────────────────────────────────
class _TierBadge extends StatelessWidget {
  final UserTier tier;

  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final label = tier == UserTier.verified
        ? 'Verified Reporter'
        : 'Community Member';
    final color = tier == UserTier.verified
        ? AppColors.green
        : AppColors.textMuted;
    final bg = tier == UserTier.verified
        ? AppColors.safeBg
        : AppColors.surface;
    final icon = tier == UserTier.verified
        ? Icons.verified_rounded
        : Icons.person_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATS SECTION
// ─────────────────────────────────────────────
class _StatsSection extends StatelessWidget {
  final _UserProfile user;

  const _StatsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _StatCard(
            value: '${user.totalReports}',
            label: 'Reports',
            icon: Icons.campaign_rounded,
            color: AppColors.green,
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: '${user.confirmedReports}',
            label: 'Confirmed',
            icon: Icons.check_circle_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: user.joinedDate.split(' ')[0],
            label: 'Joined',
            icon: Icons.calendar_today_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 2),
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
// MENU CARD
// ─────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _MenuItemTile(item: item),
              if (!isLast)
                const Divider(
                  color: AppColors.border,
                  height: 1,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MENU ITEM TILE
// ─────────────────────────────────────────────
class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                item.icon,
                color: AppColors.textMuted,
                size: 17,
              ),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            if (item.trailingWidget != null) ...[
              item.trailingWidget!,
              const SizedBox(width: 8),
            ],

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRAILING WIDGETS
// ─────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.safeBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded,
              size: 10, color: AppColors.green),
          const SizedBox(width: 3),
          Text(
            'Active',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'EN',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIGN OUT BUTTON
// ─────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.danger.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIGN OUT BOTTOM SHEET
// ─────────────────────────────────────────────
class _SignOutSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _SignOutSheet({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.danger.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
              size: 24,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Sign Out?',
            style: AppTextStyles.headingLarge,
          ),

          const SizedBox(height: 8),

          Text(
            'You\'ll need to sign in again to\naccess SafeNaija.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // Confirm button
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  'Yes, Sign Out',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Cancel
          GestureDetector(
            onTap: onCancel,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
enum UserTier { basic, verified }

class _UserProfile {
  final String name;
  final String phone;
  final String state;
  final UserTier tier;
  final int totalReports;
  final int confirmedReports;
  final String joinedDate;
  final String avatarInitials;

  const _UserProfile({
    required this.name,
    required this.phone,
    required this.state,
    required this.tier,
    required this.totalReports,
    required this.confirmedReports,
    required this.joinedDate,
    required this.avatarInitials,
  });
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.trailingWidget,
  });
}