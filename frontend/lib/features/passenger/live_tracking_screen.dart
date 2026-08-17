import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// MODEL

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

  factory Taxi.fromJson(Map<String, dynamic> json) {
    return Taxi(
      id: json['id'].toString(),
      name: json['name'] as String,
      plate: json['plate'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      etaMinutes: json['eta_minutes'] as int,
      status: (json['status'] as String) == 'available'
          ? TaxiStatus.available
          : TaxiStatus.filling,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plate': plate,
      'distance_km': distanceKm,
      'eta_minutes': etaMinutes,
      'status': status == TaxiStatus.available ? 'available' : 'filling',
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
class TaxiService {
  Future<List<Taxi>> fetchNearbyTaxis() async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate network
    return _mockTaxis;
  }
}

// Pickup point: "Mexico" (Addis Ababa) 
const LatLng pickupLocation = LatLng(9.0092, 38.7469);

final List<Taxi> _mockTaxis = [
  const Taxi(
    id: '1',
    name: 'Taxi 1',
    plate: 'AA 32-81',
    distanceKm: 1.2,
    etaMinutes: 4,
    status: TaxiStatus.available,
    latitude: 9.0125,
    longitude: 38.7510,
  ),
  const Taxi(
    id: '2',
    name: 'Taxi 2',
    plate: 'AA 14-72',
    distanceKm: 2.8,
    etaMinutes: 9,
    status: TaxiStatus.filling,
    latitude: 9.0165,
    longitude: 38.7440,
  ),
  const Taxi(
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

// SCREEN
class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  static const Color primaryBlue = Color(0xFF0B3D78);

  final MapController _mapController = MapController();
  final TaxiService _taxiService = TaxiService();

  List<Taxi> _taxis = [];
  bool _isLoading = true;
  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadTaxis();
  }

  Future<void> _loadTaxis() async {
    setState(() => _isLoading = true);
    final taxis = await _taxiService.fetchNearbyTaxis();
    if (!mounted) return;
    setState(() {
      _taxis = taxis;
      _isLoading = false;
    });
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
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              children: _taxis
                                  .map((taxi) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildTaxiCard(taxi),
                                      ))
                                  .toList(),
                            ),
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

  // Header

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: primaryBlue,
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
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
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
                  '${_taxis.length} taxis approaching',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
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


  // Real interactive OpenStreetMap via flutter_map

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pickupLocation,
              initialZoom: 14,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              // Real map tiles from OpenStreetMap — free, no API key needed.
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taxitrack',
              ),
              MarkerLayer(
                markers: [
                  // Pickup pin
                  Marker(
                    point: pickupLocation,
                    width: 70,
                    height: 60,
                    child: _buildPickupPin(),
                  ),
                  // One marker per taxi
                  ..._taxis.map(
                    (taxi) => Marker(
                      point: LatLng(taxi.latitude, taxi.longitude),
                      width: 50,
                      height: 50,
                      child: _buildTaxiMarker(taxi),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Zoom controls
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _buildMapButton(Icons.add, onTap: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                }),
                const SizedBox(height: 8),
                _buildMapButton(Icons.remove, onTap: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                }),
              ],
            ),
          ),
          // Recenter button
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildMapButton(
              Icons.my_location,
              filled: true,
              onTap: () => _mapController.move(pickupLocation, 14),
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
            color: primaryBlue,
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
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
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
            border: Border.all(color: primaryBlue, width: 2),
          ),
          child: Icon(Icons.local_taxi, color: primaryBlue, size: 14),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${taxi.etaMinutes}m',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(IconData icon, {bool filled = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 18, color: filled ? Colors.white : Colors.black87),
      ),
    );
  }


  // List header + cards

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
            color: primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_taxis.length} taxis',
            style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxiCard(Taxi taxi) {
    final bool isAvailable = taxi.status == TaxiStatus.available;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_taxi, color: primaryBlue, size: 20),
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
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
                    Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[500]),
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
                style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFFE3F6E8) : const Color(0xFFFCF2D8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAvailable ? 'available' : 'filling',
                  style: TextStyle(
                    color: isAvailable ? const Color(0xFF2E9E4F) : const Color(0xFFB8860B),
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


  // Bottom nav

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, 'Home'),
      (Icons.map_outlined, 'Track'),
      (Icons.history, 'History'),
      (Icons.person_outline, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
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
              return InkWell(
                onTap: () => setState(() => _currentNavIndex = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].$1,
                      color: selected ? primaryBlue : Colors.grey[400],
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[index].$2,
                      style: TextStyle(
                        color: selected ? primaryBlue : Colors.grey[400],
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
