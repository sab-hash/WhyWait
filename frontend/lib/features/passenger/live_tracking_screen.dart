import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// THEME
// ---------------------------------------------------------------------------

const Color kPrimaryBlue = Color(0xFF0B3D78);

// ---------------------------------------------------------------------------
// MODEL
// ---------------------------------------------------------------------------

enum TaxiStatus { available, filling }

class Taxi {
  final String id;
  final String name;
  final String plate;
  final double distanceKm;
  final int etaMinutes;
  final TaxiStatus status;
  final double latitude;
  final double longitude;

  const Taxi({
    required this.id,
    required this.name,
    required this.plate,
    required this.distanceKm,
    required this.etaMinutes,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  LatLng get location => LatLng(latitude, longitude);

  bool get isAvailable => status == TaxiStatus.available;

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
      id: json['id'].toString(),
      name: json['name'] as String,
      plate: json['plate'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      // `as int` crashes when the backend sends 4.0 — go through num first.
      etaMinutes: (json['eta_minutes'] as num).toInt(),
      status: json['status'] == 'available'
          ? TaxiStatus.available
          : TaxiStatus.filling,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plate': plate,
        'distance_km': distanceKm,
        'eta_minutes': etaMinutes,
        'status': isAvailable ? 'available' : 'filling',
        'latitude': latitude,
        'longitude': longitude,
      };
}

// ---------------------------------------------------------------------------
// SERVICE + MOCK DATA
// ---------------------------------------------------------------------------

class TaxiService {
  Future<List<Taxi>> fetchNearbyTaxis() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Return an unmodifiable copy so callers can't mutate the master list.
    return List<Taxi>.unmodifiable(_mockTaxis);
  }
}

/// Pickup point: "Mexico" (Addis Ababa)
const LatLng kPickupLocation = LatLng(9.0092, 38.7469);

const List<Taxi> _mockTaxis = <Taxi>[
  Taxi(
    id: '1',
    name: 'Taxi 1',
    plate: 'AA 32-81',
    distanceKm: 1.2,
    etaMinutes: 4,
    status: TaxiStatus.available,
    latitude: 9.0125,
    longitude: 38.7510,
  ),
  Taxi(
    id: '2',
    name: 'Taxi 2',
    plate: 'AA 14-72',
    distanceKm: 2.8,
    etaMinutes: 9,
    status: TaxiStatus.filling,
    latitude: 9.0165,
    longitude: 38.7440,
  ),
  Taxi(
    id: '3',
    name: 'Taxi 3',
    plate: 'AA 55-03',
    distanceKm: 4.1,
    etaMinutes: 13,
    status: TaxiStatus.available,
    latitude: 9.0200,
    longitude: 38.7550,
  ),
];

// ---------------------------------------------------------------------------
// SCREEN
// ---------------------------------------------------------------------------

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  static const double _minZoom = 10;
  static const double _maxZoom = 18;
  static const double _defaultZoom = 14;

  final MapController _mapController = MapController();
  final TaxiService _taxiService = TaxiService();

  List<Taxi> _taxis = const <Taxi>[];
  bool _isLoading = true;
  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadTaxis();
  }

  @override
  void dispose() {
    // flutter_map's controller holds a reference to the map state — release it.
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadTaxis() async {
    if (mounted) setState(() => _isLoading = true);

    final taxis = await _taxiService.fetchNearbyTaxis();
    if (!mounted) return; // widget was popped while awaiting

    setState(() {
      // Copy before sorting — never sort the shared mock list in place.
      _taxis = List<Taxi>.of(taxis)
        ..sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
      _isLoading = false;
    });
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final target = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(camera.center, target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMap(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: _buildListHeader(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildListBody(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader() {
    final String subtitle = _isLoading
        ? 'Finding taxis near you…'
        : '${_taxis.length} ${_taxis.length == 1 ? 'taxi' : 'taxis'} approaching';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: kPrimaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Mexico → Bole',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Real interactive OpenStreetMap via flutter_map
  // -------------------------------------------------------------------------

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: kPickupLocation,
              initialZoom: _defaultZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              // Rotation adds nothing here and fights the scroll view.
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taxitrack',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: kPickupLocation,
                    width: 70,
                    height: 60,
                    child: _buildPickupPin(),
                  ),
                  ..._taxis.map(
                    (taxi) => Marker(
                      point: taxi.location,
                      width: 50,
                      height: 50,
                      child: _buildTaxiMarker(taxi),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _buildMapButton(
                  Icons.add,
                  label: 'Zoom in',
                  onTap: () => _zoomBy(1),
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  Icons.remove,
                  label: 'Zoom out',
                  onTap: () => _zoomBy(-1),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildMapButton(
              Icons.my_location,
              label: 'Recenter',
              filled: true,
              onTap: () => _mapController.move(kPickupLocation, _defaultZoom),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: kPrimaryBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Text(
            'Mexico',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxiMarker(Taxi taxi) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryBlue, width: 2),
          ),
          child: const Icon(Icons.local_taxi, color: kPrimaryBlue, size: 14),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: kPrimaryBlue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${taxi.etaMinutes}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(
    IconData icon, {
    required String label,
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: filled ? kPrimaryBlue : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            semanticLabel: label,
            color: filled ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // List header + body
  // -------------------------------------------------------------------------

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Approaching Taxis',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_taxis.length} ${_taxis.length == 1 ? 'taxi' : 'taxis'}',
            style: const TextStyle(
              color: kPrimaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_taxis.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No taxis nearby right now.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Column(
      children: _taxis
          .map(
            (taxi) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTaxiCard(taxi),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTaxiCard(Taxi taxi) {
    final bool isAvailable = taxi.isAvailable;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_taxi,
              color: kPrimaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      taxi.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      taxi.plate,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${taxi.distanceKm} km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Text(
                      '~${taxi.etaMinutes} min',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${taxi.etaMinutes} min',
                style: const TextStyle(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFFE3F6E8)
                      : const Color(0xFFFCF2D8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAvailable ? 'available' : 'filling',
                  style: TextStyle(
                    color: isAvailable
                        ? const Color(0xFF2E9E4F)
                        : const Color(0xFFB8860B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bottom nav
  // -------------------------------------------------------------------------

  Widget _buildBottomNav() {
    const items = <(IconData, String)>[
      (Icons.home_outlined, 'Home'),
      (Icons.map_outlined, 'Track'),
      (Icons.history, 'History'),
      (Icons.person_outline, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = index == _currentNavIndex;
              final color = selected ? kPrimaryBlue : Colors.grey[400];

              return InkWell(
                onTap: () => setState(() => _currentNavIndex = index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[index].$1, color: color, size: 22),
                      const SizedBox(height: 2),
                      Text(
                        items[index].$2,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}