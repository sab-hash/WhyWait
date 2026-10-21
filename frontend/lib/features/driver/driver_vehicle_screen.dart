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
                DriverCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      _buildDocumentRow(
                        state,
                        'Registration',
                        Icons.description_rounded,
                        'registration',
                      ),
                      const Divider(
                        height: 1,
                        color: DriverTheme.divider,
                      ),
                      _buildDocumentRow(
                        state,
                        'Insurance',
                        Icons.verified_user_rounded,
                        'insurance',
                      ),
                      const Divider(
                        height: 1,
                        color: DriverTheme.divider,
                      ),
                      _buildDocumentRow(
                        state,
                        'Inspection',
                        Icons.fact_check_rounded,
                        'inspection',
                      ),
                    ],
                  ),
                ),
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

  Widget _buildDocumentRow(
    DriverState state,
    String label,
    IconData icon,
    String documentId,
  ) {
    return const SizedBox.shrink();
  }
}
  Widget _buildDocumentRow(
    DriverState state,
    String label,
    IconData icon,
    String documentId,
  ) {
    DriverDocument? document;

    try {
      document = state.documentById(documentId);
    } on StateError {
      // The requested document is not present in the local mock data.
    }

    if (document == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: DriverTheme.deepBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DriverTheme.textDark,
                ),
              ),
            ),
            const StatusChip(
              label: 'Unavailable',
              color: DriverTheme.textGrey,
              icon: Icons.info_outline_rounded,
            ),
          ],
        ),
      );
    }

    // Normal-status path arrives in the next commit.
    return const SizedBox.shrink();
  }
      final status = document.status;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: DriverTheme.deepBlue,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DriverTheme.textDark,
              ),
            ),
          ),
          StatusChip(
            label: document.statusLabel,
            color: docStatusColor(status),
            icon: docStatusIcon(status),
          ),
        ],
      ),
    );