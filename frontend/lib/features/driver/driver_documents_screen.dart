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
                _buildSummary(state),
                const SizedBox(height: 20),
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

  Widget _buildSummary(DriverState state) {
    final verification = state.verification;

    String title;
    String message;
    Color color;
    IconData icon;

    switch (verification) {
      case Verification.verified:
        title = 'All documents verified';
        message = 'You are cleared to go on duty.';
        color = DriverTheme.success;
        icon = Icons.verified_rounded;
        break;
      case Verification.pending:
        title = 'Verification pending';
        message = 'The admin is reviewing your documents.';
        color = DriverTheme.primaryBlue;
        icon = Icons.hourglass_bottom_rounded;
        break;
      case Verification.actionNeeded:
        title = 'Action needed';
        message = 'Upload the missing or expired documents.';
        color = DriverTheme.danger;
        icon = Icons.error_outline_rounded;
        break;
    }

    final attention = state.documentsNeedingAttention;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attention > 0 && verification != Verification.actionNeeded
                      ? '$attention document${attention == 1 ? '' : 's'} '
                          'expiring soon. Renew in time to stay on duty.'
                      : message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DriverTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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