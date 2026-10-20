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
    return Scaffold(
      backgroundColor: DriverTheme.background,
      appBar: buildDriverAppBar('Vehicle'),
      body: const SafeArea(
        child: Center(child: Text('Vehicle')),
      ),
    );
  }
}