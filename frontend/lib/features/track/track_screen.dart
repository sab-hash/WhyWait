import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/grpc_client.dart';
import '../../generated/whywait.pb.dart';

class TrackScreen extends StatefulWidget {
  final String station;
  final List<Map<String, dynamic>> terminals;

  const TrackScreen({
    super.key,
    required this.station,
    required this.terminals,
  });

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  // ---- Map state ----
  List<TaxiUpdate> _taxis = [];
  bool _isLoading = true;
  late LatLng _initialCenter;

  // ---- Passenger location ----
  LatLng? _userLocation;
  bool _locationPermissionGranted = false;
  final location.Location _location = location.Location();

  // ---- Route state ----
  String? _selectedDestinationId;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = false;
  List<RouteSuggestion> _routeSuggestions = [];

  // ---- Terminal ID for filtering ----
  String? _selectedTerminalId;

  @override
  void initState() {
    super.initState();
    _setInitialCenter();
    _getUserLocation();
    _listenToTaxis();
  }

  // ============================================================
  // GET USER LOCATION
  // ============================================================
  Future<void> _getUserLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _locationPermissionGranted = true;
      _location.onLocationChanged.listen((location.LocationData currentLocation) {
        setState(() {
          _userLocation = LatLng(
            currentLocation.latitude ?? 0.0,
            currentLocation.longitude ?? 0.0,
          );
        });
      });
    } else {
      print('Location permission denied');
    }
  }

  // ============================================================
  // SET INITIAL MAP CENTER
  // ============================================================
  void _setInitialCenter() {
    LatLng? center;

    for (var t in widget.terminals) {
      if (t['name'] == widget.station && t['latitude'] is num && t['longitude'] is num) {
        center = LatLng(
          (t['latitude'] as num).toDouble(),
          (t['longitude'] as num).toDouble(),
        );
        _selectedTerminalId = t['id'];
        break;
      }
    }

    if (center == null) {
      for (var t in widget.terminals) {
        if (t['latitude'] is num && t['longitude'] is num) {
          center = LatLng(
            (t['latitude'] as num).toDouble(),
            (t['longitude'] as num).toDouble(),
          );
          break;
        }
      }
    }

    _initialCenter = center ?? const LatLng(9.03, 38.74);
  }

  // ============================================================
  // TAXI STREAM (LIVE UPDATES)
  // ============================================================
  void _listenToTaxis() async {
    try {
      final stream = GrpcClient().trackTaxis(widget.station);
      await for (final update in stream) {
        setState(() {
          final index = _taxis.indexWhere((t) => t.taxiId == update.taxiId);
          if (index != -1) {
            _taxis[index] = update;
          } else {
            _taxis.add(update);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error tracking taxis: $e');
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // FETCH ROUTE FROM OSRM
  // ============================================================
  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    setState(() => _isRouteLoading = true);

    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['routes'][0];
        final geometry = route['geometry']['coordinates'];
        final duration = (route['duration'] / 60).round();

        setState(() {
          _routePoints = geometry.map<LatLng>((coord) {
            return LatLng(coord[1], coord[0]);
          }).toList();
          _routeSuggestions = [
            RouteSuggestion(description: 'Direct Route', totalDuration: duration, segments: []),
          ];
          _isRouteLoading = false;
        });

        _showRouteInfo();
      }
    } catch (e) {
      print('Error fetching route: $e');
      setState(() => _isRouteLoading = false);
    }
  }

  // ============================================================
  // SHOW ROUTE INFO BOTTOM SHEET
  // ============================================================
  void _showRouteInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Route Suggestions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._routeSuggestions.map((s) {
                return ListTile(
                  leading: const Icon(Icons.route, color: Color(0xFF1565C0)),
                  title: Text(s.description),
                  trailing: Text(
                    '${s.totalDuration} min',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                  onTap: () => Navigator.pop(context),
                );
              }).toList(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // GET TERMINAL NAME BY ID
  // ============================================================
  String _getTerminalName(String? terminalId) {
    if (terminalId == null) return '-';
    final terminal = widget.terminals.firstWhere(
      (t) => t['id'] == terminalId,
      orElse: () => {},
    );
    return terminal['name'] ?? '-';
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxis near ${widget.station}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          if (_destination != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _destination = null;
                  _selectedDestinationId = null;
                  _routePoints = [];
                  _routeSuggestions = [];
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _taxis.isEmpty && widget.terminals.isEmpty
              ? const Center(child: Text('No data available'))
              : Stack(
                  children: [
                    // ---- MAP ----
                    FlutterMap(
                      options: MapOptions(
                        center: _userLocation ?? _initialCenter,
                        zoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.whywait',
                        ),

                        // ---- TERMINAL MARKERS ----
                        if (widget.terminals.isNotEmpty)
                          MarkerLayer(
                            markers: widget.terminals.where((t) {
                              return t['latitude'] is num && t['longitude'] is num;
                            }).map((terminal) {
                              return Marker(
                                width: 100,
                                height: 60,
                                point: LatLng(
                                  (terminal['latitude'] as num).toDouble(),
                                  (terminal['longitude'] as num).toDouble(),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.blue, size: 28),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        terminal['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        // ---- PASSENGER LOCATION ----
                        if (_userLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 30,
                                height: 30,
                                point: _userLocation!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blue, width: 3),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.blue, size: 16),
                                ),
                              ),
                            ],
                          ),

                        // ---- TAXI MARKERS ----
                        MarkerLayer(
                          markers: _taxis.map((taxi) {
                            return Marker(
                              width: 50,
                              height: 50,
                              point: LatLng(taxi.latitude, taxi.longitude),
                              child: GestureDetector(
                                onTap: () => _showTaxiDetails(taxi),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_taxi,
                                      color: _getStatusColor(taxi.status),
                                      size: 40,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _getStatusColor(taxi.status), width: 1.5),
                                        ),
                                        child: Text(
                                          '${taxi.etaMinutes}m',
                                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // ---- ROUTE POLYLINE ----
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: Colors.blue,
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                      ],
                    ),

                    // ============================================================
                    // PANEL: APPROACHING TAXIS (with Terminal A & B)
                    // ============================================================
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: 200,
                          constraints: const BoxConstraints(maxHeight: 200),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Approaching Taxis',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Divider(height: 8),
                              if (_taxis.isEmpty)
                                const Text(
                                  'No taxis approaching',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                )
                              else
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _taxis.length,
                                    separatorBuilder: (_, __) => const Divider(height: 4),
                                    itemBuilder: (context, index) {
                                      final taxi = _taxis[index];
                                      // For now, show all taxis. Later filter by terminal_a/b
                                      // when proto includes those fields.
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(taxi.status),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                taxi.plate,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${taxi.etaMinutes}m',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          // 👇 Show Terminal A and B (from local terminals list)
                                          Row(
                                            children: [
                                              const Icon(Icons.flag, size: 10, color: Colors.grey),
                                              const SizedBox(width: 2),
                                              Text(
                                                'A: ${_getTerminalName(_selectedTerminalId)}',
                                                style: const TextStyle(fontSize: 8, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.flag, size: 10, color: Colors.grey),
                                              const SizedBox(width: 2),
                                              Text(
                                                'B: ${_getTerminalName(_selectedTerminalId)}',
                                                style: const TextStyle(fontSize: 8, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ============================================================
                    // BOTTOM: COMPACT DESTINATION SELECTION (VERY SMALL)
                    // ============================================================
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              // ---- Compact Dropdown ----
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'To',
                                    labelStyle: TextStyle(fontSize: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 11),
                                  value: _selectedDestinationId,
                                  items: widget.terminals.map((t) {
                                    return DropdownMenuItem<String>(
                                      value: t['id'] as String?,
                                      child: Text(t['name'], style: const TextStyle(fontSize: 10)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDestinationId = value;
                                      final term = widget.terminals.firstWhere(
                                        (t) => t['id'] == value,
                                      );
                                      _destination = LatLng(
                                        (term['latitude'] as num).toDouble(),
                                        (term['longitude'] as num).toDouble(),
                                      );
                                      _routePoints = [];
                                      _routeSuggestions = [];
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              // ---- Compact Route Button ----
                              ElevatedButton(
                                onPressed: _destination != null
                                    ? () {
                                        final start = _userLocation ?? _initialCenter;
                                        _fetchRoute(start, _destination!);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: const Size(0, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: _isRouteLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Go', style: TextStyle(fontSize: 11)),
                              ),
                              if (_routePoints.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 18),
                                  onPressed: _showRouteInfo,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ============================================================
  // TAXI DETAILS BOTTOM SHEET
  // ============================================================
  void _showTaxiDetails(TaxiUpdate taxi) {
    final distance = taxi.distanceKm.toStringAsFixed(1);
    final eta = taxi.etaMinutes < 60
        ? '${taxi.etaMinutes} min'
        : '${(taxi.etaMinutes / 60).floor()}h ${(taxi.etaMinutes % 60).floor()}min';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_taxi, color: _getStatusColor(taxi.status), size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(taxi.plate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Driver: ${taxi.driverName}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(child: _infoTile(Icons.location_on, 'Distance', '$distance km')),
                  Expanded(child: _infoTile(Icons.access_time, 'ETA', eta)),
                  Expanded(
                    child: _infoTile(
                      Icons.circle,
                      'Status',
                      taxi.status.toUpperCase(),
                      color: _getStatusColor(taxi.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? const Color(0xFF1565C0), size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================
  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'filling':
        return Colors.orange;
      case 'ontrip':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ============================================================
// ROUTE SUGGESTION MODELS
// ============================================================
class RouteSuggestion {
  final String description;
  final List<RouteSegment> segments;
  final int totalDuration;

  RouteSuggestion({
    required this.description,
    this.segments = const [],
    required this.totalDuration,
  });
}

class RouteSegment {
  final String type;
  final String from;
  final String to;
  final int duration;

  RouteSegment({
    required this.type,
    required this.from,
    required this.to,
    required this.duration,
  });
}