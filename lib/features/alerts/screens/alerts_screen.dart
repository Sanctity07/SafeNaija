// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'High', 'Medium', 'Low', 'Resolved'];

  // Mock data — replaced by Firebase later
  final List<_AlertItem> _alerts = [
    _AlertItem(
      id: '1',
      title: 'Armed Robbery near Oshodi Overpass',
      area: 'Oshodi, Lagos',
      state: 'Lagos',
      time: '8 mins ago',
      severity: AlertSeverity.high,
      confirmed: 47,
      denied: 3,
      isVerified: true,
      description:
          'Multiple armed men spotted near the overhead bridge. Motorists advised to avoid Oshodi-Apapa expressway.',
    ),
    _AlertItem(
      id: '2',
      title: 'Kidnapping Attempt Reported',
      area: 'Wuse 2, Abuja',
      state: 'FCT',
      time: '34 mins ago',
      severity: AlertSeverity.high,
      confirmed: 23,
      denied: 1,
      isVerified: true,
      description:
          'A vehicle attempted to abduct a pedestrian on Aminu Kano Crescent. Police notified.',
    ),
    _AlertItem(
      id: '3',
      title: 'Dangerous Pothole — Flooded Road',
      area: 'Mile 2, Lagos',
      state: 'Lagos',
      time: '1 hr ago',
      severity: AlertSeverity.medium,
      confirmed: 12,
      denied: 2,
      isVerified: false,
      description:
          'Major pothole causing accidents on Apapa-Oshodi expressway. Drive slowly.',
    ),
    _AlertItem(
      id: '4',
      title: 'Cult Clash — Area Boys',
      area: 'Agege, Lagos',
      state: 'Lagos',
      time: '2 hrs ago',
      severity: AlertSeverity.high,
      confirmed: 31,
      denied: 5,
      isVerified: true,
      description:
          'Rival groups clashing near Agege Motor Road. Residents advised to stay indoors.',
    ),
    _AlertItem(
      id: '5',
      title: 'Suspicious Vehicle Parked',
      area: 'GRA, Port Harcourt',
      state: 'Rivers',
      time: '3 hrs ago',
      severity: AlertSeverity.low,
      confirmed: 6,
      denied: 8,
      isVerified: false,
      description:
          'Unplated vehicle parked near a bank. Police have been alerted.',
    ),
    _AlertItem(
      id: '6',
      title: 'Road Cleared — All Clear',
      area: 'Ikeja, Lagos',
      state: 'Lagos',
      time: '5 hrs ago',
      severity: AlertSeverity.resolved,
      confirmed: 18,
      denied: 0,
      isVerified: true,
      description: 'Earlier incident on Mobolaji Bank Anthony Way resolved.',
    ),
  ];

  List<_AlertItem> get _filteredAlerts {
    if (_selectedFilter == 0) return _alerts;
    final map = {
      1: AlertSeverity.high,
      2: AlertSeverity.medium,
      3: AlertSeverity.low,
      4: AlertSeverity.resolved,
    };
    return _alerts
        .where((a) => a.severity == map[_selectedFilter])
        .toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _AlertsHeader(
                  activeCount: _alerts
                      .where((a) => a.severity == AlertSeverity.high)
                      .length,
                ),

                const SizedBox(height: 16),

                // Filter chips
                _FilterRow(
                  filters: _filters,
                  selected: _selectedFilter,
                  onSelect: (i) => setState(() => _selectedFilter = i),
                ),

                const SizedBox(height: 16),

                // Alert list
                Expanded(
                  child: _filteredAlerts.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: _filteredAlerts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final alert = _filteredAlerts[index];
                            return _AlertCard(
                              alert: alert,
                              index: index,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.alertDetail,
                                arguments: alert,
                              ),
                            );
                          },
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
class _AlertsHeader extends StatelessWidget {
  final int activeCount;

  const _AlertsHeader({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alerts', style: AppTextStyles.headingLarge),
                Text(
                  '$activeCount high severity active near you',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),

          // Search
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTER ROW
// ─────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onSelect;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  Color _chipColor(int index) {
    if (index != selected) return AppColors.textMuted;
    switch (index) {
      case 1:
        return AppColors.danger;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.green;
      case 4:
        return AppColors.textMuted;
      default:
        return AppColors.green;
    }
  }

  Color _chipBg(int index) {
    if (index != selected) return Colors.transparent;
    switch (index) {
      case 1:
        return AppColors.dangerBg;
      case 2:
        return AppColors.warningBg;
      case 3:
        return AppColors.safeBg;
      case 4:
        return AppColors.surface2;
      default:
        return AppColors.safeBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selected;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _chipBg(index),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? _chipColor(index).withOpacity(0.4)
                      : AppColors.border,
                ),
              ),
              child: Text(
                filters[index],
                style: AppTextStyles.caption.copyWith(
                  color: _chipColor(index),
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ALERT CARD
// ─────────────────────────────────────────────
class _AlertCard extends StatefulWidget {
  final _AlertItem alert;
  final int index;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Stagger by index
    Future.delayed(
      Duration(milliseconds: 60 * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _severityColor {
    switch (widget.alert.severity) {
      case AlertSeverity.high:
        return AppColors.danger;
      case AlertSeverity.medium:
        return AppColors.warning;
      case AlertSeverity.low:
        return AppColors.green;
      case AlertSeverity.resolved:
        return AppColors.textMuted;
    }
  }

  Color get _severityBg {
    switch (widget.alert.severity) {
      case AlertSeverity.high:
        return AppColors.dangerBg;
      case AlertSeverity.medium:
        return AppColors.warningBg;
      case AlertSeverity.low:
        return AppColors.safeBg;
      case AlertSeverity.resolved:
        return AppColors.surface2;
    }
  }

  String get _severityLabel {
    switch (widget.alert.severity) {
      case AlertSeverity.high:
        return 'HIGH';
      case AlertSeverity.medium:
        return 'MED';
      case AlertSeverity.low:
        return 'LOW';
      case AlertSeverity.resolved:
        return 'RESOLVED';
    }
  }

  IconData get _severityIcon {
    switch (widget.alert.severity) {
      case AlertSeverity.high:
        return Icons.warning_rounded;
      case AlertSeverity.medium:
        return Icons.info_outline_rounded;
      case AlertSeverity.low:
        return Icons.remove_red_eye_outlined;
      case AlertSeverity.resolved:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.alert.severity == AlertSeverity.high
                    ? AppColors.danger.withOpacity(0.2)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _severityBg,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: _severityColor.withOpacity(0.25),
                        ),
                      ),
                      child: Icon(
                        _severityIcon,
                        color: _severityColor,
                        size: 18,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Title + badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.alert.title,
                                  style: AppTextStyles.headingSmall.copyWith(
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _severityBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _severityLabel,
                                  style: AppTextStyles.caption.copyWith(
                                    color: _severityColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Description preview
                Text(
                  widget.alert.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Footer row
                Row(
                  children: [
                    // Location
                    const Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.alert.area,
                      style: AppTextStyles.caption,
                    ),

                    const SizedBox(width: 10),

                    // Time
                    const Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.alert.time,
                      style: AppTextStyles.caption,
                    ),

                    const Spacer(),

                    // Verified badge
                    if (widget.alert.isVerified)
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 11,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(width: 8),

                    // Confirm count
                    Text(
                      '${widget.alert.confirmed} ✓',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
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
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.safeBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.green.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.green,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All Clear',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'No alerts in this category\nnear your location.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
enum AlertSeverity { high, medium, low, resolved }

class _AlertItem {
  final String id;
  final String title;
  final String area;
  final String state;
  final String time;
  final AlertSeverity severity;
  final int confirmed;
  final int denied;
  final bool isVerified;
  final String description;

  const _AlertItem({
    required this.id,
    required this.title,
    required this.area,
    required this.state,
    required this.time,
    required this.severity,
    required this.confirmed,
    required this.denied,
    required this.isVerified,
    required this.description,
  });
}