import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../../services/driver_api_service.dart';

class DriverHomeScreen extends StatefulWidget {
  final String taxiId;
  final String driverName;

  const DriverHomeScreen({
    super.key,
    required this.taxiId,
    required this.driverName,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final loc.Location _location = loc.Location();
  loc.LocationData? _currentLocation;
  bool _isOnline = false;
  bool _isLoading = true;
  bool _isGpsActive = false;
  Timer? _locationTimer;
  DateTime _lastUpdate = DateTime.now();
  int _tripsToday = 0;
  int _earningsToday = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadStats();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      setState(() => _isLoading = false);
      _showMessage('Location permission required');
      return;
    }
    if (!await _location.serviceEnabled()) {
      await _location.requestService();
    }
    _currentLocation = await _location.getLocation();
    _isGpsActive = true;
    setState(() => _isLoading = false);
    _location.onLocationChanged.listen((data) {
      setState(() {
        _currentLocation = data;
        _isGpsActive = true;
        _lastUpdate = DateTime.now();
      });
      if (_isOnline && data.latitude != null && data.longitude != null) {
        _sendLocation(data);
      }
    });
  }

  Future<void> _sendLocation(loc.LocationData location) async {
    await DriverApiService.sendLocation(
      taxiId: widget.taxiId,
      latitude: location.latitude!,
      longitude: location.longitude!,
      speed: location.speed ?? 0,
      heading: location.heading ?? 0,
    );
    setState(() => _lastUpdate = DateTime.now());
  }

  Future<void> _toggleStatus(bool online) async {
  print('🔍 Toggling to: $online');
  print('🔍 Taxi ID: ${widget.taxiId}');

  final success = await DriverApiService.updateStatus(widget.taxiId, online);
  print('🔍 Success: $success');

  if (success) {
    setState(() => _isOnline = online);
    _showMessage(online ? '🟢 You are now ONLINE' : '🔴 You are now OFFLINE');
  } else {
    _showMessage('Failed to update status');
  }
}

  Future<void> _loadStats() async {
    final stats = await DriverApiService.getStats();
    setState(() {
      _tripsToday = stats['trips_today'] ?? 0;
      _earningsToday = stats['earnings_today'] ?? 0;
      _rating = stats['rating'] ?? 0.0;
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _logout() async {
    await DriverApiService.clearToken();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '👋 Welcome, ${widget.driverName}!',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '🚕 Taxi ID: ${widget.taxiId.substring(0, 8)}...',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          if (_currentLocation != null)
                            Text(
                              '📍 ${_currentLocation!.latitude?.toStringAsFixed(6)}, ${_currentLocation!.longitude?.toStringAsFixed(6)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ FIXED: Status Toggle Card (Added Expanded to prevent overflow)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _isOnline ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _isOnline ? '🟢 ONLINE' : '🔴 OFFLINE',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _isOnline ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isOnline,
                            onChanged: (bool value) => _toggleStatus(value),
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GPS Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isGpsActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isGpsActive ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isGpsActive ? Icons.signal_cellular_alt : Icons.signal_cellular_off,
                          color: _isGpsActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isGpsActive ? '📡 GPS Connected' : '📡 GPS Disconnected',
                          style: TextStyle(
                            color: _isGpsActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_isOnline && _isGpsActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text('$_tripsToday', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                              const Text('Trips', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text('$_earningsToday birr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                              const Text('Earnings', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text('$_rating', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                              const Text('Rating', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '🔄 Last update: ${_lastUpdate.difference(DateTime.now()).inSeconds.abs()}s ago',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', true),
            _navItem(Icons.history, 'Trips', false),
            _navItem(Icons.bar_chart, 'Reports', false),
            _navItem(Icons.person, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label screen coming soon'), duration: const Duration(seconds: 1)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? const Color(0xFF1565C0) : Colors.grey.shade500),
            Text(label, style: TextStyle(fontSize: 10, color: active ? const Color(0xFF1565C0) : Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}