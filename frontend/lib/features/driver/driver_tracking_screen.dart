import 'package:flutter/material.dart';
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
            const Expanded(
              child: Center(
                child: Text(
                  'Driver Map',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: primaryBlue,
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
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
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
        ],
      ),
    );
  }
}