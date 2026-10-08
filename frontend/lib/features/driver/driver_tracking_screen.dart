```dart
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
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DriverTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMap()),
                _buildInfoPanel(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Header
  // --------------------------------------------------------------------------

  Widget _buildHeader() {
    final seats = '${_state.seatsFilled} / ${DriverState.totalSeats} seats';

    final subtitle = !_state.isOnline
        ? 'Offline • hidden from passengers'
        : 'Demo location • $seats • ~${_state.etaMinutes} min';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: DriverTheme.deepBlue,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_state.tripFrom} → ${_state.tripTo}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _state.stage.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Map
  // --------------------------------------------------------------------------

  Widget _buildMap() {
    final stops = _state.routeStops;

    final routePoints = stops
        .map((stop) => LatLng(stop.lat, stop.lng))
        .toList();

    return Container(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DriverTheme.deepBlue,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _routeCenter,
              initialZoom: 13,
              minZoom: 10,
              maxZoom: 18,
              onMapReady: () {
                if (!mounted) return;

                _mapReady = true;

                // Center on the simulated taxi once the map is initialized.
                _moveMap(_driverLatLng, 13);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.whywait',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: DriverTheme.primaryBlue.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _buildMarkers(stops),
              ),
            ],
          ),
          _buildMapBanners(),
          _buildZoomControls(),
          _buildLocationButton(),
        ],
      ),
    );
  }

  Widget _buildMapBanners() {
    final problem = _state.problem;

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Column(
        children: [
          if (!_state.isOnline)
            _banner(
              icon: Icons.visibility_off_rounded,
              text: "You're offline. Passengers can't see your taxi.",
              color: Colors.grey.shade800,
            ),
          _banner(
            icon: Icons.info_outline_rounded,
            text: 'Showing simulated location, not live GPS.',
            color: DriverTheme.deepBlue,
          ),
          if (problem != null)
            _banner(
              icon: Icons.warning_amber_rounded,
              text: '${problem.type} reported. '
                  'ETA delay: +${problem.delayMinutes} min.',
              color: DriverTheme.warning,
            ),
        ],
      ),
    );
  }

  Widget _banner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<Station> stops) {
    final routeNames = stops.map((stop) => stop.name).toSet();
    final markers = <Marker>[];

    // Stations that are not part of the assigned route.
    for (final station in _state.stations) {
      if (routeNames.contains(station.name)) continue;

      markers.add(
        Marker(
          point: LatLng(station.lat, station.lng),
          width: 96,
          height: 48,
          child: _buildStationMarker(station),
        ),
      );
    }

    // Route stops.
    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i];

      final isStart = i == 0;
      final isEnd = i == stops.length - 1;

      final Widget child;

      if (isStart) {
        child = _buildStartMarker(stop.name);
      } else if (isEnd) {
        child = _buildDestinationFlag(stop.name);
      } else {
        child = _buildStopMarker(i, stop.name);
      }

      markers.add(
        Marker(
          point: LatLng(stop.lat, stop.lng),
          width: 96,
          height: 62,
          child: child,
        ),
      );
    }

    // The simulated driver marker is drawn last.
    if (stops.isNotEmpty) {
      markers.add(
        Marker(
          point: _driverLatLng,
          width: 46,
          height: 46,
          child: _buildDriverMarker(),
        ),
      );
    }

    return markers;
  }

  Widget _label(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStartMarker(String name) {
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
        _label('Start • $name', startGreen),
      ],
    );
  }

  Widget _buildStopMarker(int number, String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: DriverTheme.deepBlue,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: DriverTheme.deepBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 3),
        _label(name, DriverTheme.deepBlue),
      ],
    );
  }

  Widget _buildDestinationFlag(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: DriverTheme.deepBlue,
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
        _label(name, DriverTheme.deepBlue),
      ],
    );
  }

  Widget _buildStationMarker(Station station) {
    final color = station.isTerminal
        ? Colors.grey.shade700
        : Colors.grey.shade500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          station.isTerminal
              ? Icons.local_taxi_rounded
              : Icons.place_rounded,
          color: color,
          size: station.isTerminal ? 22 : 18,
        ),
        const SizedBox(height: 2),
        _label(station.name, color),
      ],
    );
  }

  Widget _buildDriverMarker() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: DriverTheme.primaryBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_bus_filled_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      left: 12,
      bottom: 12,
      child: Column(
        children: [
          _buildMapButton(
            Icons.add,
            onTap: () {
              if (!_mapReady) return;

              final zoom = _mapController.camera.zoom;
              _moveMap(
                _mapController.camera.center,
                (zoom + 1).clamp(10.0, 18.0),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMapButton(
            Icons.remove,
            onTap: () {
              if (!_mapReady) return;

              final zoom = _mapController.camera.zoom;
              _moveMap(
                _mapController.camera.center,
                (zoom - 1).clamp(10.0, 18.0),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Positioned(
      right: 12,
      bottom: 12,
      child: _buildMapButton(
        Icons.my_location,
        filled: true,
        onTap: () {
          if (_state.routeStops.isEmpty) return;
          _moveMap(_driverLatLng, 14.5);
        },
      ),
    );
  }

  Widget _buildMapButton(
    IconData icon, {
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: filled ? DriverTheme.deepBlue : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
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
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Information panel
  // --------------------------------------------------------------------------

  Widget _buildInfoPanel() {
    final stage = _state.stage;
    final next = _state.nextStop;

    final hasDeparted =
        stage == TripStage.departed ||
        stage == TripStage.onRoute;

    final String nextTitle;
    final String? nextTrailing;

    if (stage == TripStage.arrived || next == null) {
      nextTitle = 'Arrived at ${_state.tripTo}';
      nextTrailing = null;
    } else {
      nextTitle = next.stop.name;
      nextTrailing = hasDeparted ? '~${next.minutes} min' : null;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: DriverTheme.cardDecoration(radius: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const RoundIcon(
                icon: Icons.flag_rounded,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage == TripStage.arrived
                          ? 'Destination'
                          : 'Next stop',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (nextTrailing != null)
                Text(
                  nextTrailing,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DriverTheme.primaryBlue,
                  ),
                )
              else if (!hasDeparted && stage != TripStage.arrived)
                const StatusChip(
                  label: 'Not departed',
                  color: DriverTheme.textGrey,
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            color: DriverTheme.divider,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.event_seat_rounded,
                  value:
                      '${_state.seatsFilled} / ${DriverState.totalSeats}',
                  label: 'Seats filled',
                ),
              ),
              const StatDivider(height: 50),
              Expanded(
                child: StatTile(
                  icon: Icons.timeline_rounded,
                  value: stage.label,
                  label: 'Trip state',
                ),
              ),
              const StatDivider(height: 50),
              Expanded(
                child: StatTile(
                  icon: Icons.access_time_rounded,
                  value: stage == TripStage.arrived
                      ? 'Now'
                      : '~${_state.etaMinutes} min',
                  label: 'ETA to ${_state.tripTo}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```