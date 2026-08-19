import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteStop {
  final int number;
  final double latitude;
  final double longitude;

  const RouteStop({
    required this.number,
    required this.latitude,
    required this.longitude,
  });
}

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
  static const Color primaryBlue = Color(0xFF0B3D78);
  static const Color startGreen = Color(0xFF2E9E4F);

  final MapController _mapController = MapController();

  static const LatLng startPoint = LatLng(9.0092, 38.7469);
  static const LatLng driverPosition = LatLng(9.0110, 38.7472);

  final List<RouteStop> stops = const [
    RouteStop(number: 1, latitude: 9.0140, longitude: 38.7490),
    RouteStop(number: 2, latitude: 9.0175, longitude: 38.7520),
    RouteStop(number: 3, latitude: 9.0205, longitude: 38.7555),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMap()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: primaryBlue,
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.maybePop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.fromLabel} → ${widget.toLabel}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                '${widget.passengersOnBoard} / '
                '${widget.passengersTotal} passengers • '
                '~${widget.etaMinutes} min',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryBlue,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: driverPosition,
              initialZoom: 14.5,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taxitrack',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: startPoint,
                    width: 60,
                    height: 56,
                    child: _buildStartMarker(),
                  ),
                  Marker(
                    point: driverPosition,
                    width: 46,
                    height: 46,
                    child: _buildDriverMarker(),
                  ),
                  ...stops.map(
                    (stop) => Marker(
                      point: LatLng(
                        stop.latitude,
                        stop.longitude,
                      ),
                      width: 42,
                      height: 42,
                      child: _buildStopMarker(stop),
                    ),
                  ),
                  Marker(
                    point: LatLng(
                      stops.last.latitude,
                      stops.last.longitude,
                    ),
                    width: 70,
                    height: 60,
                    child: _buildDestinationFlag(),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Column(
              children: [
                _buildMapButton(
                  Icons.add,
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  Icons.remove,
                  onTap: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildMapButton(
              Icons.my_location,
              filled: true,
              onTap: () {
                _mapController.move(
                  driverPosition,
                  14.5,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: startGreen,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: startGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Start',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverMarker() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.directions_bus_filled_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildStopMarker(RouteStop stop) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryBlue,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${stop.number}',
        style: const TextStyle(
          color: primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDestinationFlag() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.toLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(
    IconData icon, {
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}