import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final double rating;
  final int totalTrips;
  final double earningsToday;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleColor;

  const DriverProfileScreen({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    required this.rating,
    required this.totalTrips,
    required this.earningsToday,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleColor,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  static const Color primaryBlue = Color(0xFF0B3D78);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const ClipOval(
              child: Icon(
                Icons.person,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.phoneNumber,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}