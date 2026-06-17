// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/theme.dart';

class SafeZonesScreen extends StatefulWidget {
  const SafeZonesScreen({super.key});

  @override
  State<SafeZonesScreen> createState() => _SafeZonesScreenState();
}

class _SafeZonesScreenState extends State<SafeZonesScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  GoogleMapController? _mapController;

  final List<_SafeZone> _zones = [
    _SafeZone(
      id: '1',
      label: 'Home',
      address: '12 Adeniyi Jones, Ikeja',
      icon: Icons.home_rounded,
      color: AppColors.green,
      location: const LatLng(6.6018, 3.3515),
      radius: 500,
      isActive: true,
    ),
    _SafeZone(
      id: '2',
      label: 'Work',
      address: 'Victoria Island, Lagos',
      icon: Icons.work_rounded,
      color: AppColors.warning,
      location: const LatLng(6.4281, 3.4219),
      radius: 300,
      isActive: true,
    ),
    _SafeZone(
      id: '3',
      label: 'School',
      address: 'University of Lagos, Akoka',
      icon: Icons.school_rounded,
      color: Color(0xFF5E9BF0),
      location: const LatLng(6.5158, 3.3906),
      radius: 400,
      isActive: false,
    ),
  ];

  int _selectedZone = 0;

  Set<Circle> get _circles {
    return _zones.map((zone) {
      final isSelected = _zones.indexOf(zone) == _selectedZone;
      return Circle(
        circleId: CircleId(zone.id),
        center: zone.location,
        radius: zone.radius.toDouble(),
        fillColor: zone.color.withOpacity(isSelected ? 0.15 : 0.08),
        strokeColor: zone.color.withOpacity(isSelected ? 0.6 : 0.3),
        strokeWidth: isSelected ? 2 : 1,
      );
    }).toSet();
  }

  Set<Marker> get _markers {
    return _zones.map((zone) {
      return Marker(
        markerId: MarkerId(zone.id),
        position: zone.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          zone.color == AppColors.green
              ? BitmapDescriptor.hueGreen
              : zone.color == AppColors.warning
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueBlue,
        ),
        onTap: () {
          setState(() => _selectedZone = _zones.indexOf(zone));
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(zone.location),
          );
        },
      );
    }).toSet();
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
    _mapController?.dispose();
    super.dispose();
  }

  void _addZone() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddZoneSheet(
        onAdd: (label, address) {
          setState(() {
            _zones.add(
              _SafeZone(
                id: DateTime.now().toString(),
                label: label,
                address: address,
                icon: Icons.location_on_rounded,
                color: AppColors.green,
                location: const LatLng(6.5244, 3.3792),
                radius: 300,
                isActive: true,
              ),
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteZone(int index) {
    setState(() {
      _zones.removeAt(index);
      if (_selectedZone >= _zones.length) {
        _selectedZone = _zones.length - 1;
      }
    });
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
                _SafeZonesHeader(
                  onBack: () => Navigator.pop(context),
                  onAdd: _addZone,
                ),

                // Map
                _ZoneMap(
                  circles: _circles,
                  markers: _markers,
                  selectedZone: _zones.isNotEmpty
                      ? _zones[_selectedZone]
                      : null,
                  onMapCreated: (c) {
                    _mapController = c;
                    c.setMapStyle(_mapStyle);
                  },
                ),

                // Zone list
                Expanded(
                  child: _zones.isEmpty
                      ? const _EmptyZones()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: _zones.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _ZoneTile(
                              zone: _zones[index],
                              isSelected: index == _selectedZone,
                              onTap: () {
                                setState(() => _selectedZone = index);
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLng(
                                    _zones[index].location,
                                  ),
                                );
                              },
                              onToggle: (val) {
                                setState(
                                  () => _zones[index] = _SafeZone(
                                    id: _zones[index].id,
                                    label: _zones[index].label,
                                    address: _zones[index].address,
                                    icon: _zones[index].icon,
                                    color: _zones[index].color,
                                    location: _zones[index].location,
                                    radius: _zones[index].radius,
                                    isActive: val,
                                  ),
                                );
                              },
                              onDelete: () => _deleteZone(index),
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
class _SafeZonesHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAdd;

  const _SafeZonesHeader({
    required this.onBack,
    required this.onAdd,
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
                Text('Safe Zones', style: AppTextStyles.headingLarge),
                Text(
                  'Places you want to monitor closely',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.safeBg,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Zone',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
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
// ZONE MAP
// ─────────────────────────────────────────────
class _ZoneMap extends StatelessWidget {
  final Set<Circle> circles;
  final Set<Marker> markers;
  final _SafeZone? selectedZone;
  final Function(GoogleMapController) onMapCreated;

  const _ZoneMap({
    required this.circles,
    required this.markers,
    required this.selectedZone,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: selectedZone?.location ?? const LatLng(6.5244, 3.3792),
          zoom: 12,
        ),
        circles: circles,
        markers: markers,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ZONE TILE
// ─────────────────────────────────────────────
class _ZoneTile extends StatelessWidget {
  final _SafeZone zone;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ZoneTile({
    required this.zone,
    required this.isSelected,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? zone.color.withOpacity(0.4)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: zone.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: zone.color.withOpacity(0.25),
                ),
              ),
              child: Icon(zone.icon, color: zone.color, size: 20),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.label,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    zone.address,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${zone.radius}m radius',
                    style: AppTextStyles.caption.copyWith(
                      color: zone.color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Toggle
            GestureDetector(
              onTap: () => onToggle(!zone.isActive),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 22,
                decoration: BoxDecoration(
                  color: zone.isActive ? zone.color : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: zone.isActive ? zone.color : AppColors.border,
                  ),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: zone.isActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Delete
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.danger.withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 14,
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
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyZones extends StatelessWidget {
  const _EmptyZones();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.safeBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.green.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.location_off_outlined,
              color: AppColors.green,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text('No Safe Zones', style: AppTextStyles.headingSmall),
          const SizedBox(height: 6),
          Text(
            'Add places you want to\nmonitor for nearby incidents.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD ZONE SHEET
// ─────────────────────────────────────────────
class _AddZoneSheet extends StatefulWidget {
  final Function(String label, String address) onAdd;

  const _AddZoneSheet({required this.onAdd});

  @override
  State<_AddZoneSheet> createState() => _AddZoneSheetState();
}

class _AddZoneSheetState extends State<_AddZoneSheet> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  int _selectedType = 0;

  final List<_ZoneType> _types = const [
    _ZoneType(label: 'Home', icon: Icons.home_rounded, color: AppColors.green),
    _ZoneType(label: 'Work', icon: Icons.work_rounded, color: AppColors.warning),
    _ZoneType(label: 'School', icon: Icons.school_rounded, color: Color(0xFF5E9BF0)),
    _ZoneType(label: 'Other', icon: Icons.location_on_rounded, color: AppColors.textMuted),
  ];

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Safe Zone', style: AppTextStyles.headingLarge),
          const SizedBox(height: 4),
          Text(
            'You\'ll get alerts for incidents near this place.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 20),

          // Zone type selector
          Row(
            children: _types.asMap().entries.map((entry) {
              final index = entry.key;
              final type = entry.value;
              final isSelected = index == _selectedType;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = index;
                      _labelController.text = type.label;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.color.withOpacity(0.1)
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? type.color.withOpacity(0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type.icon,
                          color: isSelected ? type.color : AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.label,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? type.color : AppColors.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Label field
          TextFormField(
            controller: _labelController,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Zone label (e.g. Home)',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(
                Icons.label_outline_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Address field
          TextFormField(
            controller: _addressController,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter address or area',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Add button
          GestureDetector(
            onTap: () {
              if (_labelController.text.isNotEmpty &&
                  _addressController.text.isNotEmpty) {
                widget.onAdd(
                  _labelController.text,
                  _addressController.text,
                );
              }
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Add Zone',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.black),
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
class _SafeZone {
  final String id;
  final String label;
  final String address;
  final IconData icon;
  final Color color;
  final LatLng location;
  final int radius;
  final bool isActive;

  const _SafeZone({
    required this.id,
    required this.label,
    required this.address,
    required this.icon,
    required this.color,
    required this.location,
    required this.radius,
    required this.isActive,
  });
}

class _ZoneType {
  final String label;
  final IconData icon;
  final Color color;

  const _ZoneType({
    required this.label,
    required this.icon,
    required this.color,
  });
}

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
  { "featureType": "transit", "stylers": [{ "visibility": "off" }] }
]
''';