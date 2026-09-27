import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/grpc_client.dart';
import '../../generated/whywait.pb.dart';

class DriverMapScreen extends StatefulWidget {
  final String fromLabel;
  final String toLabel;
  final int passengersOnBoard;
  final int passengersTotal;
  final int etaMinutes;

  const DriverMapScreen({
    super.key,
    required this.fromLabel,
    required this.toLabel,
    required this.passengersOnBoard,
    required this.passengersTotal,
    required this.etaMinutes,
  });

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  // ---- Map state ----
  bool _isLoading = true;
  late LatLng _initialCenter = const LatLng(9.03, 38.74); // Default Addis Ababa center

  // ---- Driver's own taxi ----
  LatLng? _driverPosition;
  String _driverPlate = 'AA 32-81'; // TODO: fetch from backend
  String _driverStatus = 'available';

  // ---- Passenger location (mock) ----
  LatLng? _passengerLocation;

  // ---- Terminals ----
  List<Map<String, dynamic>> _terminals = [];

  // ---- Route state ----
  String? _selectedDestinationId;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = false;
  List<RouteSuggestion> _routeSuggestions = [];

  // ---- Location ----
  final location.Location _location = location.Location();

  @override
  void initState() {
    super.initState();
    _loadTerminals();
    _getDriverLocation();
    _getPassengerLocation();
  }

  // ============================================================
  // LOAD TERMINALS
  // ============================================================
  Future<void> _loadTerminals() async {
    try {
      final response = await GrpcClient().getTerminals();
      setState(() {
        _terminals = response.terminals.map((t) => {
          'id': t.id,
          'name': t.name,
          'latitude': t.latitude,
          'longitude': t.longitude,
        }).toList();
        _isLoading = false;
      });
      _setInitialCenter();
    } catch (e) {
      print('Error loading terminals: $e');
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // SET INITIAL CENTER
  // ============================================================
  void _setInitialCenter() {
    // Try to center on driver's assigned route start
    final fromTerminal = _terminals.firstWhere(
      (t) => t['name'] == widget.fromLabel,
      orElse: () => {},
    );
    if (fromTerminal.isNotEmpty) {
      _initialCenter = LatLng(
        fromTerminal['latitude'] as double,
        fromTerminal['longitude'] as double,
      );
    } else if (_driverPosition != null) {
      _initialCenter = _driverPosition!;
    } else {
      _initialCenter = const LatLng(9.03, 38.74);
    }
  }

  // ============================================================
  // GET DRIVER LOCATION (GPS)
  // ============================================================
  Future<void> _getDriverLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _location.onLocationChanged.listen((location.LocationData currentLocation) {
        setState(() {
          _driverPosition = LatLng(
            currentLocation.latitude ?? 0.0,
            currentLocation.longitude ?? 0.0,
          );
        });
      });
    } else {
      print('Location permission denied');
      // Fallback: use a default position (e.g., Bole)
      _driverPosition = const LatLng(9.0, 38.76);
    }
  }

  // ============================================================
  // GET PASSENGER LOCATION (Mock)
  // ============================================================
  Future<void> _getPassengerLocation() async {
    // TODO: fetch from backend via gRPC
    // For now, use a mock location near Bole
    _passengerLocation = const LatLng(9.005, 38.755);
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
  // SHOW ROUTE INFO
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
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

  // ============================================================
  // GET TERMINAL NAME BY ID
  // ============================================================
  String _getTerminalName(String? terminalId) {
    if (terminalId == null) return '-';
    final terminal = _terminals.firstWhere(
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('${widget.fromLabel} → ${widget.toLabel}'),
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
          : _terminals.isEmpty
              ? const Center(child: Text('No data available'))
              : Stack(
                  children: [
                    // ---- MAP ----
                    FlutterMap(
                      options: MapOptions(
                        center: _driverPosition ?? _initialCenter,
                        zoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.whywait',
                        ),

                        // ---- TERMINAL MARKERS (with names) ----
                        if (_terminals.isNotEmpty)
                          MarkerLayer(
                            markers: _terminals.where((t) {
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

                        // ---- DRIVER LOCATION MARKER (Blue taxi with label) ----
                        if (_driverPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 60,
                                height: 60,
                                point: _driverPosition!,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.local_taxi,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // ---- PASSENGER LOCATION MARKER (Green dot) ----
                        if (_passengerLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 30,
                                height: 30,
                                point: _passengerLocation!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green, width: 2),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.green, size: 16),
                                ),
                              ),
                            ],
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

                    // ---- BOTTOM: COMPACT CONTROLS ----
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
                              // ---- Passengers Info ----
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    const Icon(Icons.people_alt, size: 16, color: Color(0xFF1565C0)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.passengersOnBoard}/${widget.passengersTotal}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // ---- ETA ----
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Color(0xFF1565C0)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.etaMinutes} min',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // ---- Destination Dropdown (compact) ----
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'To',
                                    labelStyle: TextStyle(fontSize: 10),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 11),
                                  value: _selectedDestinationId,
                                  items: _terminals.map((t) {
                                    return DropdownMenuItem<String>(
                                      value: t['id'] as String?,
                                      child: Text(t['name'], style: const TextStyle(fontSize: 10)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDestinationId = value;
                                      final term = _terminals.firstWhere(
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
                              // ---- Route Button ----
                              ElevatedButton(
                                onPressed: _destination != null && _driverPosition != null
                                    ? () {
                                        _fetchRoute(_driverPosition!, _destination!);
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