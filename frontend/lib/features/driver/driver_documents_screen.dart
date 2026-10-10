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
    final status = document.status;
    final color = docStatusColor(status);
    final expiry = document.expiry;

    String buttonLabel;
    switch (status) {
      case DocStatus.missing:
        buttonLabel = 'Upload';
        break;
      case DocStatus.expired:
      case DocStatus.expiring:
        buttonLabel = 'Upload renewed';
        break;
      case DocStatus.pending:
      case DocStatus.verified:
        buttonLabel = 'Replace';
        break;
    }

    return DriverCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundIcon(icon: document.icon, color: DriverTheme.deepBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DriverTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      document.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (expiry != null && document.uploaded) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Expires ${DriverTheme.formatDate(expiry)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DriverTheme.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusChip(
                label: document.statusLabel,
                color: color,
                icon: docStatusIcon(status),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text(buttonLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DriverTheme.primaryBlue,
                  side: BorderSide(
                    color: DriverTheme.primaryBlue.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}