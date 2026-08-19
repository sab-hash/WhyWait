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

  bool _isOnline = true;

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

              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStatsCard(),
                ),
              ),
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
            child: ClipOval(
              child: widget.avatarUrl != null
                  ? Image.network(
                      widget.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _avatarFallback();
                      },
                    )
                  : _avatarFallback(),
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
          const SizedBox(height: 16),
          _buildOnlineToggle(),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  Widget _buildOnlineToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOnline = !_isOnline;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _isOnline
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: _isOnline
              ? null
              : Border.all(color: Colors.white54),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline
                    ? const Color(0xFF2E9E4F)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isOnline
                  ? 'Online — accepting rides'
                  : 'Offline',
              style: TextStyle(
                color: _isOnline ? primaryBlue : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statColumn(
              '${widget.rating.toStringAsFixed(1)} ★',
              'Rating',
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statColumn(
              '${widget.totalTrips}',
              'Trips',
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statColumn(
              '${widget.earningsToday.toStringAsFixed(0)} ETB',
              'Today',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.grey[200],
    );
  }
}