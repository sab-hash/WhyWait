import 'package:flutter/material.dart';

import '../../models/driver_models.dart';
import 'driver_documents_screen.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// Vehicle information, document status and maintenance details.
/// Opened from the driver's profile.
class DriverVehicleScreen extends StatelessWidget {
  const DriverVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DriverState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final vehicle = state.vehicle;

        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Vehicle'),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                Center(child: Text(vehicle.model)),
                const SizedBox(height: 22),
                const DriverGroupLabel('DOCUMENT STATUS'),
                const SizedBox(height: 10),
                const SizedBox(height: 120),
                const SizedBox(height: 22),
                const DriverGroupLabel('MAINTENANCE'),
                const SizedBox(height: 10),
                const SizedBox(height: 80),
                const SizedBox(height: 22),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}