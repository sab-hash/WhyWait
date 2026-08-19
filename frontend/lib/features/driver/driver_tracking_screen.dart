import 'package:flutter/material.dart';

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