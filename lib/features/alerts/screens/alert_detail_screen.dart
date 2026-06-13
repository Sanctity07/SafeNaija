import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/theme.dart';

class AlertDetailScreen extends StatefulWidget {
  const AlertDetailScreen({super.key});

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasConfirmed = false;
  bool _hasDenied = false;
  int _confirmCount = 47;
  int _denyCount = 3;

  GoogleMapController? _mapController;

  // Mock — replaced by route arguments later
  final _alert = _AlertDetail(
    id: '1',
    title: 'Armed Robbery near Oshodi Overpass',
    area: 'Oshodi, Lagos',
    state: 'Lagos',
    lga: 'Oshodi-Isolo',
    time: '8 mins ago',
    fullTime: 'Today, 8:43 AM',
    severity: DetailSeverity.high,
    confirmed: 47,
    denied: 3,
    isVerified: true,
    reportedBy: 'Anonymous',
    reporterTier: 'Verified Reporter',
    description:
        'Multiple armed men spotted near the Oshodi overhead bridge. '
        'They were seen approaching vehicles in traffic and forcing '
        'motorists to hand over valuables. At least 3 vehicles affected. '
        'Police have been called but not yet on scene.',
    location: LatLng(6.4550, 3.3841),
    updates: [
      _AlertUpdate(
        text: 'Police sighted entering the area',
        time: '12 mins ago',
      ),
      _AlertUpdate(
        text: 'Second report received from nearby street',
        time: '6 mins ago',
      ),
    ],
  );

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
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
    _mapController?.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_hasDenied || _hasConfirmed) return;
    setState(() {
      _hasConfirmed = true;
      _confirmCount++;
    });
    _showVoteSnack('Thanks for confirming. Stay safe.', AppColors.green);
  }

  void _deny() {
    if (_hasConfirmed || _hasDenied) return;
    setState(() {
      _hasDenied = true;
      _denyCount++;
    });
    _showVoteSnack('Noted. We\'ll review this report.', AppColors.warning);
  }

  void _showVoteSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _share() {
    // Wire to share_plus later
  }

  Color get _severityColor {
    switch (_alert.severity) {
      case DetailSeverity.high:
        return AppColors.danger;
      case DetailSeverity.medium:
        return AppColors.warning;
      case DetailSeverity.low:
        return AppColors.green;
    }
  }

  Color get _severityBg {
    switch (_alert.severity) {
      case DetailSeverity.high:
        return AppColors.dangerBg;
      case DetailSeverity.medium:
        return AppColors.warningBg;
      case DetailSeverity.low:
        return AppColors.safeBg;
    }
  }

  String get _severityLabel {
    switch (_alert.severity) {
      case DetailSeverity.high:
        return 'HIGH SEVERITY';
      case DetailSeverity.medium:
        return 'MEDIUM SEVERITY';
      case DetailSeverity.low:
        return 'LOW SEVERITY';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Hero header
              SliverToBoxAdapter(
                child: _HeroHeader(
                  alert: _alert,
                  severityColor: _severityColor,
                  severityBg: _severityBg,
                  severityLabel: _severityLabel,
                  onBack: () => Navigator.pop(context),
                  onShare: _share,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini map
                      _MiniMap(
                        location: _alert.location,
                        severityColor: _severityColor,
                        onMapCreated: (c) => _mapController = c,
                      ),

                      const SizedBox(height: 20),

                      // Description
                      _SectionTitle(title: 'What Happened'),
                      const SizedBox(height: 10),
                      _DescriptionCard(description: _alert.description),

                      const SizedBox(height: 20),

                      // Reporter info
                      _SectionTitle(title: 'Reported By'),
                      const SizedBox(height: 10),
                      _ReporterCard(
                        reportedBy: _alert.reportedBy,
                        tier: _alert.reporterTier,
                        isVerified: _alert.isVerified,
                        time: _alert.fullTime,
                      ),

                      const SizedBox(height: 20),

                      // Location info
                      _SectionTitle(title: 'Location'),
                      const SizedBox(height: 10),
                      _LocationCard(
                        area: _alert.area,
                        state: _alert.state,
                        lga: _alert.lga,
                      ),

                      const SizedBox(height: 20),

                      // Updates
                      if (_alert.updates.isNotEmpty) ...[
                        _SectionTitle(title: 'Live Updates'),
                        const SizedBox(height: 10),
                        _UpdatesCard(updates: _alert.updates),
                        const SizedBox(height: 20),
                      ],

                      // Vote section
                      _SectionTitle(title: 'Is this still active?'),
                      const SizedBox(height: 10),
                      _VoteRow(
                        confirmCount: _confirmCount,
                        denyCount: _denyCount,
                        hasConfirmed: _hasConfirmed,
                        hasDenied: _hasDenied,
                        onConfirm: _confirm,
                        onDeny: _deny,
                      ),

                      const SizedBox(height: 14),

                      // Share button
                      _ShareButton(onTap: _share),

                      const SizedBox(height: 40),
                    ],
                  ),
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
// HERO HEADER
// ─────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final _AlertDetail alert;
  final Color severityColor;
  final Color severityBg;
  final String severityLabel;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _HeroHeader({
    required this.alert,
    required this.severityColor,
    required this.severityBg,
    required this.severityLabel,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            severityColor.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
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

              const Spacer(),

              // Share
              GestureDetector(
                onTap: onShare,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Severity tag
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: severityBg,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: severityColor.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: severityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  severityLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: severityColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            alert.title,
            style: AppTextStyles.displaySmall.copyWith(
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Meta row
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: Icons.location_on_outlined,
                label: alert.area,
              ),
              _MetaChip(
                icon: Icons.access_time_rounded,
                label: alert.time,
              ),
              if (alert.isVerified)
                _MetaChip(
                  icon: Icons.verified_rounded,
                  label: 'Verified',
                  color: AppColors.green,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MINI MAP
// ─────────────────────────────────────────────
class _MiniMap extends StatelessWidget {
  final LatLng location;
  final Color severityColor;
  final Function(GoogleMapController) onMapCreated;

  const _MiniMap({
    required this.location,
    required this.severityColor,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('incident'),
                  position: location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              liteModeEnabled: true,
            ),

            // Gradient overlay bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.bg.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Open maps button
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 11,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Open Maps',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.green,
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
    );
  }
}

// ─────────────────────────────────────────────
// DESCRIPTION CARD
// ─────────────────────────────────────────────
class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        description,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.65,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REPORTER CARD
// ─────────────────────────────────────────────
class _ReporterCard extends StatelessWidget {
  final String reportedBy;
  final String tier;
  final bool isVerified;
  final String time;

  const _ReporterCard({
    required this.reportedBy,
    required this.tier,
    required this.isVerified,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isVerified
                    ? AppColors.green.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: isVerified ? AppColors.green : AppColors.textMuted,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reportedBy,
                  style: AppTextStyles.headingSmall.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (isVerified) ...[
                      const Icon(
                        Icons.verified_rounded,
                        size: 11,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        tier,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else
                      Text(
                        'Community Member',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ],
            ),
          ),

          Text(
            time,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOCATION CARD
// ─────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  final String area;
  final String state;
  final String lga;

  const _LocationCard({
    required this.area,
    required this.state,
    required this.lga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.safeBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.green.withOpacity(0.25),
              ),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                area,
                style: AppTextStyles.headingSmall.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                '$lga · $state State',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPDATES CARD
// ─────────────────────────────────────────────
class _UpdatesCard extends StatelessWidget {
  final List<_AlertUpdate> updates;

  const _UpdatesCard({required this.updates});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: updates.asMap().entries.map((entry) {
          final index = entry.key;
          final update = entry.value;
          final isLast = index == updates.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                    ),
                ],
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        update.text,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        update.time,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VOTE ROW
// ─────────────────────────────────────────────
class _VoteRow extends StatelessWidget {
  final int confirmCount;
  final int denyCount;
  final bool hasConfirmed;
  final bool hasDenied;
  final VoidCallback onConfirm;
  final VoidCallback onDeny;

  const _VoteRow({
    required this.confirmCount,
    required this.denyCount,
    required this.hasConfirmed,
    required this.hasDenied,
    required this.onConfirm,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Confirm
        Expanded(
          child: GestureDetector(
            onTap: onConfirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: hasConfirmed
                    ? AppColors.safeBg
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasConfirmed
                      ? AppColors.green
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: hasConfirmed
                        ? AppColors.green
                        : AppColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Confirm ($confirmCount)',
                    style: AppTextStyles.caption.copyWith(
                      color: hasConfirmed
                          ? AppColors.green
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Deny
        Expanded(
          child: GestureDetector(
            onTap: onDeny,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: hasDenied ? AppColors.dangerBg : AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasDenied
                      ? AppColors.danger
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: hasDenied
                        ? AppColors.danger
                        : AppColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Deny ($denyCount)',
                    style: AppTextStyles.caption.copyWith(
                      color: hasDenied
                          ? AppColors.danger
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SHARE BUTTON
// ─────────────────────────────────────────────
class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShareButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.share_outlined,
              color: AppColors.textMuted,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Share Alert',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
enum DetailSeverity { high, medium, low }

class _AlertDetail {
  final String id;
  final String title;
  final String area;
  final String state;
  final String lga;
  final String time;
  final String fullTime;
  final DetailSeverity severity;
  final int confirmed;
  final int denied;
  final bool isVerified;
  final String reportedBy;
  final String reporterTier;
  final String description;
  final LatLng location;
  final List<_AlertUpdate> updates;

  const _AlertDetail({
    required this.id,
    required this.title,
    required this.area,
    required this.state,
    required this.lga,
    required this.time,
    required this.fullTime,
    required this.severity,
    required this.confirmed,
    required this.denied,
    required this.isVerified,
    required this.reportedBy,
    required this.reporterTier,
    required this.description,
    required this.location,
    required this.updates,
  });
}

class _AlertUpdate {
  final String text;
  final String time;

  const _AlertUpdate({required this.text, required this.time});
}