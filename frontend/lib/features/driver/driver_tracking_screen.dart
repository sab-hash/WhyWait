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
    RouteStop(
      number: 1,
      latitude: 9.0140,
      longitude: 38.7490,
    ),
    RouteStop(
      number: 2,
      latitude: 9.0175,
      longitude: 38.7520,
    ),
    RouteStop(
      number: 3,
      latitude: 9.0205,
      longitude: 38.7555,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.fromLabel} → ${widget.toLabel}',
        ),
      ),
      body: const Center(
        child: Text(
          'Driver Map',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}