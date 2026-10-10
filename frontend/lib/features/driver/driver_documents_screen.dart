import 'package:flutter/material.dart';

import '../../models/driver_models.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

/// Documents: driver's license, vehicle registration, insurance and the
/// other required documents, with upload and verification status
/// (Verified, Pending, Expiring in X days). Opened from Profile or Vehicle.
class DriverDocumentsScreen extends StatelessWidget {
  const DriverDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DriverState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Documents'),
          body: const SafeArea(
            child: Center(child: Text('Documents')),
          ),
        );
      },
    );
  }
}