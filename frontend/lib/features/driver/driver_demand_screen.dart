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

  @override
  Widget build(BuildContext context) {
    final stations = _state.stations.toList()
      ..sort((a, b) => b.waiting.compareTo(a.waiting));

    final total = stations.fold<int>(0, (sum, s) => sum + s.waiting);
    final busyCount =
        stations.where((s) => s.waiting >= busyThreshold).length;

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
                  // Station tiles added in next commit.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}