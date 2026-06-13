import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  int _currentIndex = 0;

  // Temp mock data — will be replaced by Firebase
  final List<_IncidentMarker> _incidents = [
    _IncidentMarker(
      id: '1',
      title: 'Armed Robbery',
      location: const LatLng(6.4550, 3.3841),
      severity: IncidentSeverity.high,
      area: 'Oshodi, Lagos',
      time: '8 mins ago',
      confirmed: 47,
    ),
    _IncidentMarker(
      id: '2',
      title: 'Dangerous Road',
      location: const LatLng(6.4350, 3.3941),
      severity: IncidentSeverity.medium,
      area: 'Mile 2, Lagos',
      time: '23 mins ago',
      confirmed: 12,
    ),
    _IncidentMarker(
      id: '3',
      title: 'Suspicious Activity',
      location: const LatLng(6.4650, 3.4041),
      severity: IncidentSeverity.low,
      area: 'Surulere, Lagos',
      time: '1 hr ago',
      confirmed: 5,
    ),
  ];

  late AnimationController _sheetController;
  late Animation<double> _sheetAnimation;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final DraggableScrollableController _dragController =
      DraggableScrollableController();

  Set<Marker> _markers = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.4550, 3.3841),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();

    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sheetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sheetController, curve: Curves.easeOut),
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _startAnimations();
    _buildMarkers();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sheetController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fabController.forward();
  }

  void _buildMarkers() {
    final markers = <Marker>{};
    for (final incident in _incidents) {
      markers.add(
        Marker(
          markerId: MarkerId(incident.id),
          position: incident.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            incident.severity == IncidentSeverity.high
                ? BitmapDescriptor.hueRed
                : incident.severity == IncidentSeverity.medium
                    ? BitmapDescriptor.hueOrange
                    : BitmapDescriptor.hueGreen,
          ),
          onTap: () => _onMarkerTapped(incident),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  void _onMarkerTapped(_IncidentMarker incident) {
    Navigator.pushNamed(
      context,
      AppRoutes.alertDetail,
      arguments: incident,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_mapStyle);
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _fabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // Top overlay — header
          SafeArea(
            child: FadeTransition(
              opacity: _sheetAnimation,
              child: _MapHeader(
                onNotificationTap: () =>
                    Navigator.pushNamed(context, AppRoutes.alerts),
              ),
            ),
          ),

          // FAB — Report button
          Positioned(
            right: 20,
            bottom: 220,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: _ReportFAB(
                onTap: () => Navigator.pushNamed(context, AppRoutes.report),
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 20,
            bottom: 290,
            child: ScaleTransition(
              scale: _fabAnimation,
              child: _LocationButton(
                onTap: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(_initialPosition),
                  );
                },
              ),
            ),
          ),

          // Bottom sheet
          FadeTransition(
            opacity: _sheetAnimation,
            child: DraggableScrollableSheet(
              controller: _dragController,
              initialChildSize: 0.28,
              minChildSize: 0.12,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return _IncidentsSheet(
                  scrollController: scrollController,
                  incidents: _incidents,
                  onIncidentTap: (incident) => Navigator.pushNamed(
                    context,
                    AppRoutes.alertDetail,
                    arguments: incident,
                  ),
                );
              },
            ),
          ),

          // Bottom nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                switch (index) {
                  case 1:
                    Navigator.pushNamed(context, AppRoutes.alerts);
                    break;
                  case 2:
                    Navigator.pushNamed(context, AppRoutes.report);
                    break;
                  case 3:
                    Navigator.pushNamed(context, AppRoutes.profile);
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAP HEADER
// ─────────────────────────────────────────────
class _MapHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const _MapHeader({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Location block
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pulse dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR LOCATION',
                        style: AppTextStyles.caption.copyWith(
                          letterSpacing: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Lagos Island, Lagos',
                        style: AppTextStyles.headingSmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  // Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
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
// REPORT FAB
// ─────────────────────────────────────────────
class _ReportFAB extends StatelessWidget {
  final VoidCallback onTap;

  const _ReportFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOCATION BUTTON
// ─────────────────────────────────────────────
class _LocationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LocationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: AppColors.green,
          size: 20,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INCIDENTS BOTTOM SHEET
// ─────────────────────────────────────────────
class _IncidentsSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<_IncidentMarker> incidents;
  final ValueChanged<_IncidentMarker> onIncidentTap;

  const _IncidentsSheet({
    required this.scrollController,
    required this.incidents,
    required this.onIncidentTap,
  });

  @override
  Widget build(BuildContext context) {
    final high = incidents
        .where((i) => i.severity == IncidentSeverity.high)
        .length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Nearby Alerts',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(width: 8),
                  if (high > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: AppColors.danger.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$high ACTIVE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                'See all',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Incident list
          ...incidents.map(
            (incident) => _IncidentTile(
              incident: incident,
              onTap: () => onIncidentTap(incident),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INCIDENT TILE
// ─────────────────────────────────────────────
class _IncidentTile extends StatelessWidget {
  final _IncidentMarker incident;
  final VoidCallback onTap;

  const _IncidentTile({required this.incident, required this.onTap});

  Color get _severityColor {
    switch (incident.severity) {
      case IncidentSeverity.high:
        return AppColors.danger;
      case IncidentSeverity.medium:
        return AppColors.warning;
      case IncidentSeverity.low:
        return AppColors.green;
    }
  }

  Color get _severityBg {
    switch (incident.severity) {
      case IncidentSeverity.high:
        return AppColors.dangerBg;
      case IncidentSeverity.medium:
        return AppColors.warningBg;
      case IncidentSeverity.low:
        return AppColors.safeBg;
    }
  }

  String get _severityLabel {
    switch (incident.severity) {
      case IncidentSeverity.high:
        return 'HIGH';
      case IncidentSeverity.medium:
        return 'MED';
      case IncidentSeverity.low:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Severity icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _severityBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _severityColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                incident.severity == IncidentSeverity.high
                    ? Icons.warning_rounded
                    : incident.severity == IncidentSeverity.medium
                        ? Icons.info_outline_rounded
                        : Icons.remove_red_eye_outlined,
                color: _severityColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          incident.title,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        incident.area,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        incident.time,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 11,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${incident.confirmed} confirmed',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

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
// BOTTOM NAV
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map_rounded,
            label: 'Map',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: 'Alerts',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            badge: true,
          ),
          _NavItem(
            icon: Icons.add_circle_outline_rounded,
            activeIcon: Icons.add_circle_rounded,
            label: 'Report',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.green.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.green : AppColors.textMuted,
                  size: 22,
                ),
                if (badge)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
enum IncidentSeverity { high, medium, low }

class _IncidentMarker {
  final String id;
  final String title;
  final LatLng location;
  final IncidentSeverity severity;
  final String area;
  final String time;
  final int confirmed;

  const _IncidentMarker({
    required this.id,
    required this.title,
    required this.location,
    required this.severity,
    required this.area,
    required this.time,
    required this.confirmed,
  });
}

// ─────────────────────────────────────────────
// DARK MAP STYLE
// ─────────────────────────────────────────────
const String _mapStyle = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#1a1a1a" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#888888" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#0a0a0a" }] },
  { "featureType": "road", "elementType": "geometry", "stylers": [{ "color": "#2a2a2a" }] },
  { "featureType": "road.arterial", "elementType": "geometry", "stylers": [{ "color": "#333333" }] },
  { "featureType": "road.highway", "elementType": "geometry", "stylers": [{ "color": "#3a3a3a" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#0f1a24" }] },
  { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
  { "featureType": "transit", "stylers": [{ "visibility": "off" }] },
  { "featureType": "administrative", "elementType": "geometry", "stylers": [{ "color": "#2a2a2a" }] }
]
''';