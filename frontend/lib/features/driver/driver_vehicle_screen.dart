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
                _buildHero(vehicle),
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

                _buildMaintenance(vehicle),

                const SizedBox(height: 22),

                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const DriverDocumentsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.folder_copy_outlined,
                      size: 20,
                    ),
                    label: const Text(
                      'Manage documents',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DriverTheme.primaryBlue,
                      side: BorderSide(
                        color: DriverTheme.primaryBlue.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Vehicle overview
  // --------------------------------------------------------------------------

  Widget _buildHero(DriverVehicle vehicle) {
    return DriverCard(
      child: Column(
        children: [
          const RoundIcon(
            icon: Icons.directions_bus_rounded,
            color: DriverTheme.deepBlue,
            size: 72,
          ),
          const SizedBox(height: 14),

          Text(
            vehicle.model,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DriverTheme.textDark,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: DriverTheme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: DriverTheme.divider,
              ),
            ),
            child: Text(
              vehicle.plate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: DriverTheme.textDark,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Divider(
            height: 1,
            color: DriverTheme.divider,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.local_taxi_rounded,
                  value: vehicle.type,
                  label: 'Vehicle type',
                ),
              ),
              const StatDivider(),
              Expanded(
                child: StatTile(
                  icon: Icons.event_seat_rounded,
                  value: '${vehicle.seats}',
                  label: 'Seats',
                ),
              ),
              const StatDivider(),
              Expanded(
                child: StatTile(
                  icon: Icons.palette_outlined,
                  value: vehicle.color,
                  label: 'Color',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Documents
  // --------------------------------------------------------------------------

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
  }

  // --------------------------------------------------------------------------
  // Maintenance
  // --------------------------------------------------------------------------

  Widget _buildMaintenance(DriverVehicle vehicle) {
    final daysLeft = vehicle.serviceDaysLeft;

    final String label;
    final Color color;
    final IconData icon;

    if (daysLeft < 0) {
      final overdueDays = daysLeft.abs();

      label = 'Overdue by $overdueDays '
          '${overdueDays == 1 ? 'day' : 'days'}';

      color = DriverTheme.danger;
      icon = Icons.error_rounded;
    } else if (daysLeft == 0) {
      label = 'Service due today';
      color = DriverTheme.warning;
      icon = Icons.schedule_rounded;
    } else if (daysLeft <= 14) {
      label = 'Service due in $daysLeft '
          '${daysLeft == 1 ? 'day' : 'days'}';

      color = DriverTheme.warning;
      icon = Icons.schedule_rounded;
    } else {
      label = 'Good condition';
      color = DriverTheme.success;
      icon = Icons.check_circle_rounded;
    }

    return DriverCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.build_circle_outlined,
                color: DriverTheme.deepBlue,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Maintenance status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DriverTheme.textDark,
                  ),
                ),
              ),
              Flexible(
                child: StatusChip(
                  label: label,
                  color: color,
                  icon: icon,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: DriverTheme.divider,
          ),

          const SizedBox(height: 14),

          _dateRow(
            'Last service',
            DriverTheme.formatDate(vehicle.lastService),
          ),

          const SizedBox(height: 10),

          _dateRow(
            'Next service',
            DriverTheme.formatDate(vehicle.nextService),
          ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: DriverTheme.textGrey,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DriverTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
