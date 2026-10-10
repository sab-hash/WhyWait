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
        final documents = state.documents;

        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Documents'),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                for (final document in documents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDocumentCard(context, state, document),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    DriverState state,
    DriverDocument document,
  ) {
    return const DriverCard(
      padding: EdgeInsets.all(16),
      child: Text('Document'),
    );
  }
}