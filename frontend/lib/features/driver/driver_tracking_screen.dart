import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/driver_models.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// Map tab for the driver's assigned route.
///
/// IMPORTANT: The position currently comes from DriverState's route
/// simulation. It is not a real GPS location or a live backend update.
class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  static const Color startGreen = Color(0xFF2E9E4F);

  final MapController _mapController = MapController();
  final DriverState _state = DriverState.instance;

  static const LatLng _routeCenter = LatLng(9.0040, 38.7645);

  bool _mapReady = false;

  LatLng get _driverLatLng {
    final position = _state.driverPosition;
    return LatLng(position.lat, position.lng);
  }

  void _moveMap(LatLng center, double zoom) {
    if (!_mapReady) return;

    try {
      _mapController.move(center, zoom);
    } catch (_) {
      // The map may have been detached while the screen was changing.
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverTheme.background,
      body: const SafeArea(
        child: Center(child: Text('Map')),
      ),
    );
  }
}