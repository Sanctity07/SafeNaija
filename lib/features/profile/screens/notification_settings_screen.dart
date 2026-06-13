import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Alert type toggles
  bool _highSeverity = true;
  bool _mediumSeverity = true;
  bool _lowSeverity = false;
  bool _verifiedOnly = false;
  bool _nearbyOnly = true;

  // Notification channels
  bool _pushNotifications = true;
  bool _soundAlerts = true;
  bool _vibration = true;
  bool _quietHours = false;

  // Radius
  double _alertRadius = 5.0;

  // Quiet hours
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 6, minute: 0);

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

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietStart : _quietEnd,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.green,
              surface: AppColors.surface2,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietStart = picked;
        } else {
          _quietEnd = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification settings saved.',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
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
            child: Column(
              children: [
                // Header
                _NotifHeader(
                  onBack: () => Navigator.pop(context),
                  onSave: _saveSettings,
                ),

                // Body
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    children: [

                      // Alert radius
                      _SectionLabel(label: 'Alert Radius'),
                      const SizedBox(height: 12),
                      _RadiusCard(
                        radius: _alertRadius,
                        onChanged: (val) =>
                            setState(() => _alertRadius = val),
                      ),

                      const SizedBox(height: 24),

                      // Severity filters
                      _SectionLabel(label: 'Alert Severity'),
                      const SizedBox(height: 12),
                      _ToggleCard(
                        items: [
                          _ToggleItem(
                            icon: Icons.warning_rounded,
                            iconColor: AppColors.danger,
                            iconBg: AppColors.dangerBg,
                            label: 'High Severity',
                            subtitle: 'Armed robbery, kidnapping, clashes',
                            value: _highSeverity,
                            onChanged: (val) =>
                                setState(() => _highSeverity = val),
                          ),
                          _ToggleItem(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.warning,
                            iconBg: AppColors.warningBg,
                            label: 'Medium Severity',
                            subtitle: 'Dangerous roads, cult activity',
                            value: _mediumSeverity,
                            onChanged: (val) =>
                                setState(() => _mediumSeverity = val),
                          ),
                          _ToggleItem(
                            icon: Icons.remove_red_eye_outlined,
                            iconColor: AppColors.green,
                            iconBg: AppColors.safeBg,
                            label: 'Low Severity',
                            subtitle: 'Suspicious activity, minor incidents',
                            value: _lowSeverity,
                            onChanged: (val) =>
                                setState(() => _lowSeverity = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Report filters
                      _SectionLabel(label: 'Report Filters'),
                      const SizedBox(height: 12),
                      _ToggleCard(
                        items: [
                          _ToggleItem(
                            icon: Icons.verified_rounded,
                            iconColor: AppColors.green,
                            iconBg: AppColors.safeBg,
                            label: 'Verified Reports Only',
                            subtitle:
                                'Only show alerts confirmed by the community',
                            value: _verifiedOnly,
                            onChanged: (val) =>
                                setState(() => _verifiedOnly = val),
                          ),
                          _ToggleItem(
                            icon: Icons.my_location_rounded,
                            iconColor: AppColors.warning,
                            iconBg: AppColors.warningBg,
                            label: 'Nearby Alerts Only',
                            subtitle: 'Alerts within your set radius only',
                            value: _nearbyOnly,
                            onChanged: (val) =>
                                setState(() => _nearbyOnly = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Notification channels
                      _SectionLabel(label: 'Notification Channels'),
                      const SizedBox(height: 12),
                      _ToggleCard(
                        items: [
                          _ToggleItem(
                            icon: Icons.notifications_active_rounded,
                            iconColor: AppColors.green,
                            iconBg: AppColors.safeBg,
                            label: 'Push Notifications',
                            subtitle: 'Receive alerts on your device',
                            value: _pushNotifications,
                            onChanged: (val) =>
                                setState(() => _pushNotifications = val),
                          ),
                          _ToggleItem(
                            icon: Icons.volume_up_rounded,
                            iconColor: AppColors.warning,
                            iconBg: AppColors.warningBg,
                            label: 'Sound Alerts',
                            subtitle: 'Play sound for new incidents',
                            value: _soundAlerts,
                            onChanged: (val) =>
                                setState(() => _soundAlerts = val),
                          ),
                          _ToggleItem(
                            icon: Icons.vibration_rounded,
                            iconColor: AppColors.textMuted,
                            iconBg: AppColors.surface,
                            label: 'Vibration',
                            subtitle: 'Vibrate on new alerts',
                            value: _vibration,
                            onChanged: (val) =>
                                setState(() => _vibration = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Quiet hours
                      _SectionLabel(label: 'Quiet Hours'),
                      const SizedBox(height: 12),
                      _QuietHoursCard(
                        isEnabled: _quietHours,
                        quietStart: _quietStart,
                        quietEnd: _quietEnd,
                        onToggle: (val) =>
                            setState(() => _quietHours = val),
                        onStartTap: () => _pickTime(true),
                        onEndTap: () => _pickTime(false),
                        formatTime: _formatTime,
                      ),

                      const SizedBox(height: 28),

                      // Save button
                      _SaveButton(onTap: _saveSettings),
                    ],
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
class _NotifHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _NotifHeader({
    required this.onBack,
    required this.onSave,
  });

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: AppTextStyles.headingLarge,
                ),
                Text(
                  'Control what alerts you receive',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSave,
            child: Text(
              'Save',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.green,
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
// RADIUS CARD
// ─────────────────────────────────────────────
class _RadiusCard extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onChanged;

  const _RadiusCard({
    required this.radius,
    required this.onChanged,
  });

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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.safeBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.green.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Radius',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Receive alerts within this distance',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.safeBg,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.green.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${radius.toInt()} km',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.green,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.green,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.green,
              overlayColor: AppColors.green.withOpacity(0.15),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
            ),
            child: Slider(
              value: radius,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: onChanged,
            ),
          ),

          // Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 km', style: AppTextStyles.caption),
                Text('25 km', style: AppTextStyles.caption),
                Text('50 km', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOGGLE CARD
// ─────────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  final List<_ToggleItem> items;

  const _ToggleCard({required this.items});

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
              _ToggleRow(item: item),
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

class _ToggleRow extends StatelessWidget {
  final _ToggleItem item;

  const _ToggleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: item.iconColor.withOpacity(0.2),
              ),
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 16,
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
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // Toggle
          GestureDetector(
            onTap: () => item.onChanged(!item.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: item.value ? AppColors.green : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: item.value
                      ? AppColors.green
                      : AppColors.border,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: item.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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
// QUIET HOURS CARD
// ─────────────────────────────────────────────
class _QuietHoursCard extends StatelessWidget {
  final bool isEnabled;
  final TimeOfDay quietStart;
  final TimeOfDay quietEnd;
  final ValueChanged<bool> onToggle;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final String Function(TimeOfDay) formatTime;

  const _QuietHoursCard({
    required this.isEnabled,
    required this.quietStart,
    required this.quietEnd,
    required this.onToggle,
    required this.onStartTap,
    required this.onEndTap,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Toggle row
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.bedtime_outlined,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiet Hours',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mute non-critical alerts at night',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onToggle(!isEnabled),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppColors.green
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isEnabled
                            ? AppColors.green
                            : AppColors.border,
                      ),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isEnabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time pickers — only visible when enabled
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(
                  color: AppColors.border,
                  height: 1,
                  indent: 56,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Row(
                    children: [
                      // Start time
                      Expanded(
                        child: _TimePickerButton(
                          label: 'From',
                          time: formatTime(quietStart),
                          onTap: onStartTap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      // End time
                      Expanded(
                        child: _TimePickerButton(
                          label: 'To',
                          time: formatTime(quietEnd),
                          onTap: onEndTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: isEnabled
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 9),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 14,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SAVE BUTTON
// ─────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Center(
          child: Text(
            'Save Settings',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────
class _ToggleItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}