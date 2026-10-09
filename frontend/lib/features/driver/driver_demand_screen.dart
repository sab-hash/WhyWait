import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/driver_models.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// Demand map: how many passengers wait at each station.
/// Busy stations are highlighted so the driver knows where passengers are.
/// The numbers come from passengers joining queues in the passenger app.
/// Opened from the "Waiting Passengers" card on Home.
class DriverDemandScreen extends StatefulWidget {
  const DriverDemandScreen({super.key});

  @override
  State<DriverDemandScreen> createState() => _DriverDemandScreenState();
}

class _DriverDemandScreenState extends State<DriverDemandScreen> {
  /// From this many waiting passengers a station is "busy".
  static const int busyThreshold = 15;
  static const int mediumThreshold = 8;

  final MapController _mapController = MapController();
  final DriverState _state = DriverState.instance;

  Color _levelColor(int waiting) {
    if (waiting >= busyThreshold) return Colors.deepOrange;
    if (waiting >= mediumThreshold) return DriverTheme.warning;
    return DriverTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final stations = _state.stations.toList()
      ..sort((a, b) => b.waiting.compareTo(a.waiting));

    final total = stations.fold<int>(0, (sum, s) => sum + s.waiting);
    final busyCount =
        stations.where((s) => s.waiting >= busyThreshold).length;
    final maxWaiting = stations.first.waiting;
    final routeNames = _state.routeStops.map((s) => s.name).toSet();

    return Scaffold(
      backgroundColor: DriverTheme.background,
      appBar: buildDriverAppBar('Demand Map'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  DriverCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            icon: Icons.groups_rounded,
                            value: '$total',
                            label: 'Waiting now',
                          ),
                        ),
                        const StatDivider(),
                        Expanded(
                          child: StatTile(
                            icon: Icons.local_fire_department_rounded,
                            value: '$busyCount',
                            label: 'Busy stations',
                            valueColor:
                                busyCount > 0 ? Colors.deepOrange : null,
                          ),
                        ),
                        const StatDivider(),
                        Expanded(
                          child: StatTile(
                            icon: Icons.trending_up_rounded,
                            value: stations.first.name,
                            label: 'Busiest',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const DriverGroupLabel('WAITING PASSENGERS PER STATION'),
                  const SizedBox(height: 10),
                  for (final station in stations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildStationTile(
                        station,
                        maxWaiting: maxWaiting,
                        onRoute: routeNames.contains(station.name),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(List<Station> stations) {
    return Container(
      height: 280,
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DriverTheme.primaryBlue, width: 2),
      ),
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(9.0170, 38.7680),
          initialZoom: 11.8,
          minZoom: 10,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.whywait',
          ),
          MarkerLayer(
            markers: [
              for (final station in stations)
                _buildMarker(station),
            ],
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(Station station) {
    final color = _levelColor(station.waiting);
    final busy = station.waiting >= busyThreshold;
    final size = (26 + station.waiting * 1.0).clamp(30.0, 56.0).toDouble();

    return Marker(
      point: LatLng(station.lat, station.lng),
      width: 96,
      height: size + 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: busy ? 0.55 : 0.25),
                  blurRadius: busy ? 14 : 6,
                  spreadRadius: busy ? 3 : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${station.waiting}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              station.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationTile(
    Station station, {
    required int maxWaiting,
    required bool onRoute,
  }) {
    final color = _levelColor(station.waiting);
    final busy = station.waiting >= busyThreshold;

    return DriverCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        _mapController.move(LatLng(station.lat, station.lng), 14);
      },
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${station.waiting}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: DriverTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      station.isTerminal ? 'Terminal' : 'Station',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (onRoute) ...[
                const StatusChip(
                  label: 'Your route',
                  color: DriverTheme.primaryBlue,
                ),
                const SizedBox(width: 6),
              ],
              if (busy)
                const StatusChip(
                  label: 'Busy',
                  color: Colors.deepOrange,
                  icon: Icons.local_fire_department_rounded,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: maxWaiting == 0 ? 0 : station.waiting / maxWaiting,
              minHeight: 7,
              backgroundColor: DriverTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}