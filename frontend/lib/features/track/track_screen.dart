import 'dart:async';
import 'dart:math'; // 👈 Import for sqrt() and asin()
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';

class TrackScreen extends StatefulWidget {
  final String fromStation;
  final String toStation;

  const TrackScreen({
    super.key,
    required this.fromStation,
    required this.toStation,
  });

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  // ==================== CONSTANTS ====================
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFFE3F2FD);

  // ==================== MAP CONTROLLER ====================
  final MapController _mapController = MapController();
  double _currentZoom = 13;
  final LatLng _defaultCenter = const LatLng(9.0103, 38.7598);

  // ==================== ROUTE ====================
  List<LatLng> _routePoints = [];

  // ==================== ANIMATED TAXIS ====================
  final Map<String, _AnimatedTaxi> _animatedTaxis = {};
  Timer? _refreshTimer;
  Timer? _animationTimer;
  bool _isLoading = true;
  DateTime _lastUpdate = DateTime.now();

  // ==================== LIFECYCLE ====================
  @override
  void initState() {
    super.initState();
    _loadTaxis();
    _fetchRoute();

    // Refresh every 5 seconds (polling)
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadTaxis();
    });

    // Animation loop (60 FPS)
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateAnimation();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }

  // ==================== ANIMATION ENGINE ====================
  void _updateAnimation() {
    bool needsUpdate = false;
    for (var taxi in _animatedTaxis.values) {
      if (taxi.update()) {
        needsUpdate = true;
      }
    }
    if (needsUpdate) {
      setState(() {});
    }
  }

  // ==================== LOAD TAXIS FROM BACKEND ====================
  Future<void> _loadTaxis() async {
    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/taxis/approaching?station=${Uri.encodeComponent(widget.fromStation)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newTaxis = data['taxis'] ?? [];

        setState(() {
          _isLoading = false;
          _lastUpdate = DateTime.now();
          _syncAnimatedTaxis(newTaxis);
        });
      }
    } catch (e) {
      print('❌ Error loading taxis: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ==================== SYNC TAXI DATA WITH ANIMATION ====================
  void _syncAnimatedTaxis(List<dynamic> newTaxis) {
    final newIds = <String>{};

    for (var taxiData in newTaxis) {
      final id = taxiData['id'] ?? taxiData['plate'];
      newIds.add(id);

      final lat = taxiData['latitude'] ?? 0.0;
      final lng = taxiData['longitude'] ?? 0.0;
      final target = LatLng(lat, lng);

      if (_animatedTaxis.containsKey(id)) {
        _animatedTaxis[id]!.setTarget(
          target,
          status: taxiData['status'] ?? 'available',
          eta: taxiData['eta_minutes'] ?? 0,
        );
      } else {
        _animatedTaxis[id] = _AnimatedTaxi(
          startPosition: target,
          targetPosition: target,
          plate: taxiData['plate'] ?? 'Unknown',
          status: taxiData['status'] ?? 'available',
          eta: taxiData['eta_minutes'] ?? 0,
        );
      }
    }

    _animatedTaxis.removeWhere((key, value) => !newIds.contains(key));
  }

  // ==================== BUILD ANIMATED MARKERS ====================
  List<Marker> _buildAnimatedMarkers() {
    final List<Marker> markers = [];

    // Station Marker
    markers.add(
      Marker(
        point: _defaultCenter,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
      ),
    );

    // Taxi Markers (Animated)
    for (var entry in _animatedTaxis.entries) {
      final taxi = entry.value;
      markers.add(
        Marker(
          point: taxi.currentPosition,
          width: 30,
          height: 30,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🚕 Taxi ${taxi.plate} - ETA: ${taxi.eta}min'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.local_taxi, color: Colors.green, size: 30),
          ),
        ),
      );
    }

    return markers;
  }

  // ==================== ROUTE FETCHING ====================
  Future<void> _fetchRoute() async {
    try {
      final url = Uri.parse(
        '${ApiService.baseUrl}/routes/calculate?from_lat=9.0103&from_lng=38.7598&to_lat=8.9806&to_lng=38.7578',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final polylineEncoded = data['route']['polyline'] as String?;
        if (polylineEncoded != null) {
          final points = _decodePolyline(polylineEncoded);
          setState(() {
            _routePoints = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  // ==================== POLYLINE DECODER ====================
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapSection(),
                  _buildApproachingTaxisSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.fromStation} → ${widget.toStation}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_animatedTaxis.length} taxis approaching',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MAP SECTION ====================
  Widget _buildMapSection() {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.whywait',
              ),
              MarkerLayer(markers: _buildAnimatedMarkers()),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
            ],
          ),
          // Zoom Controls
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _zoomButton(Icons.add, () {
                  _currentZoom += 1;
                  _mapController.move(_defaultCenter, _currentZoom);
                }),
                const SizedBox(height: 4),
                _zoomButton(Icons.remove, () {
                  _currentZoom -= 1;
                  if (_currentZoom < 1) _currentZoom = 1;
                  _mapController.move(_defaultCenter, _currentZoom);
                }),
              ],
            ),
          ),
          // Current Location Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                _currentZoom = 14;
                _mapController.move(_defaultCenter, _currentZoom);
              },
              backgroundColor: primaryBlue,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: Colors.black87,
      ),
    );
  }

  // ==================== TAXI LIST SECTION ====================
  Widget _buildApproachingTaxisSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Approaching Taxis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_animatedTaxis.length} taxis',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_animatedTaxis.isEmpty)
            const Center(child: Text('No taxis approaching'))
          else
            ..._animatedTaxis.values.map((taxi) => _buildTaxiCard(taxi)),
        ],
      ),
    );
  }

  Widget _buildTaxiCard(_AnimatedTaxi taxi) {
    final distanceKm = (taxi.currentDistance ?? 0.0).toStringAsFixed(1);
    final status = taxi.status;

    Color statusColor;
    String statusText;
    switch (status) {
      case 'available':
        statusColor = Colors.green;
        statusText = 'Available';
        break;
      case 'filling':
        statusColor = Colors.orange;
        statusText = 'Filling';
        break;
      case 'on_trip':
        statusColor = Colors.red;
        statusText = 'On Trip';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_taxi, color: primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taxi ${taxi.plate}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      Text(' $distanceKm km   ', style: const TextStyle(fontSize: 12)),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      Text(' ~${taxi.eta}min', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${taxi.eta}min',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION ====================
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Home', false),
            _navItem(Icons.location_on_rounded, 'Track', true),
            _navItem(Icons.history, 'History', false),
            _navItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Home') {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryBlue : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? primaryBlue : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ANIMATED TAXI CLASS ====================
class _AnimatedTaxi {
  LatLng currentPosition;
  LatLng startPosition;
  LatLng targetPosition;
  String plate;
  String status;
  int eta;
  double progress = 1.0;
  double? currentDistance;
  final double animationSpeed = 0.025;

  _AnimatedTaxi({
    required this.startPosition,
    required this.targetPosition,
    required this.plate,
    required this.status,
    required this.eta,
  }) : currentPosition = startPosition;

  void setTarget(LatLng newTarget, {String? status, int? eta}) {
    if (newTarget != targetPosition) {
      startPosition = currentPosition;
      targetPosition = newTarget;
      progress = 0.0;
      currentDistance = _calculateDistance(currentPosition, targetPosition);
    }
    if (status != null) this.status = status;
    if (eta != null) this.eta = eta;
  }

  bool update() {
    if (progress >= 1.0) return false;

    progress += animationSpeed;
    if (progress > 1.0) progress = 1.0;

    final lat = startPosition.latitude +
        (targetPosition.latitude - startPosition.latitude) * progress;
    final lng = startPosition.longitude +
        (targetPosition.longitude - startPosition.longitude) * progress;
    currentPosition = LatLng(lat, lng);

    if (progress < 1.0) {
      currentDistance = _calculateDistance(currentPosition, targetPosition);
    }

    return true;
  }

  double _calculateDistance(LatLng from, LatLng to) {
    const R = 6371; // Earth radius in km
    final dLat = (to.latitude - from.latitude) * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;
    final a = (dLat / 2) * (dLat / 2) +
        (from.latitude * pi / 180) *
            (to.latitude * pi / 180) *
            (dLng / 2) *
            (dLng / 2);
    final c = 2 * asin(sqrt(a));
    return R * c;
  }
}