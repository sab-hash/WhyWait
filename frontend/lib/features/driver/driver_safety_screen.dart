import 'package:flutter/material.dart';

import '../../models/driver_models.dart';
import 'driver_state.dart';
import 'driver_theme.dart';
import 'driver_widgets.dart';

// ============================================================================
// Shared actions (also used by the quick actions on Home)
// ============================================================================

/// Asks for confirmation, then sends an SOS.
Future<void> showSosDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Send SOS alert?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Your live location will be sent to the admin, the terminal and '
          'your emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DriverTheme.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      );
    },
  );

  if (confirmed == true && context.mounted) {
    DriverState.instance.triggerSos();
    showDriverSnack(context, 'SOS sent. Help is being notified.');
  }
}

/// Bottom sheet to report a breakdown, a delay or an incident.
/// Reporting updates the ETA passengers see.
Future<void> showReportProblemSheet(
  BuildContext context, {
  int initialType = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReportProblemSheet(initialType: initialType),
  );
}

class _ReportProblemSheet extends StatefulWidget {
  final int initialType;

  const _ReportProblemSheet({required this.initialType});

  @override
  State<_ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<_ReportProblemSheet> {
  // Type, icon and the default extra minutes added to passenger ETAs.
  static const List<(String, IconData, int)> _types = [
    ('Breakdown', Icons.build_rounded, 20),
    ('Delay', Icons.schedule_rounded, 10),
    ('Incident', Icons.report_problem_rounded, 20),
  ];

  static const List<int> _delayOptions = [10, 20, 30];

  final TextEditingController _noteController = TextEditingController();

  late int _selected;
  late int _delay;
  bool _endTrip = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Prevent an invalid index from causing a RangeError.
    _selected = widget.initialType.clamp(0, _types.length - 1);
    _delay = _types[_selected].$3;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final state = DriverState.instance;
    final type = _types[_selected].$1;

    try {
      state.reportProblem(
        type: type,
        delayMinutes: _delay,
        note: _noteController.text.trim(),
      );

      final endedTrip = _endTrip && state.isOnTrip;

      if (endedTrip) {
        state.endTripInterrupted();
      }

      final messenger = ScaffoldMessenger.of(context);

      Navigator.pop(context);

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: DriverTheme.textDark,
          content: Text(
            endedTrip
                ? '$type reported. Trip ended as interrupted.'
                : '$type reported. Passenger ETAs are updated (+$_delay min).',
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to submit driver report: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      showDriverSnack(
        context,
        'Could not submit the report. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = DriverState.instance;
    final canEndTrip = state.isOnTrip && _types[_selected].$1 != 'Delay';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report a problem',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Passengers see an updated ETA after you report.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(_types.length, (index) {
                final selected = index == _selected;
                final color = selected
                    ? DriverTheme.primaryBlue
                    : DriverTheme.textGrey;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == _types.length - 1 ? 0 : 10,
                    ),
                    child: InkWell(
                      onTap: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _selected = index;
                                _delay = _types[index].$3;
                                _endTrip = false;
                              });
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? DriverTheme.primaryBlue.withValues(alpha: 0.10)
                              : DriverTheme.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? DriverTheme.primaryBlue
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(_types[index].$2, color: color, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              _types[index].$1,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            const Text(
              'Extra time to add to passenger ETAs',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _delayOptions.map((minutes) {
                return ChoiceChip(
                  label: Text('+$minutes min'),
                  selected: _delay == minutes,
                  selectedColor:
                      DriverTheme.primaryBlue.withValues(alpha: 0.15),
                  onSelected: _isSubmitting
                      ? null
                      : (_) => setState(() => _delay = minutes),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              enabled: !_isSubmitting,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (canEndTrip) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _endTrip,
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _endTrip = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: DriverTheme.primaryBlue,
                title: const Text(
                  "I can't continue: end this trip as interrupted",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DriverTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Report',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Safety screen
// ============================================================================

/// SOS, emergency contacts, share location and report a problem.
/// Opened from Profile.
class DriverSafetyScreen extends StatelessWidget {
  const DriverSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DriverState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DriverTheme.background,
          appBar: buildDriverAppBar('Safety'),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              children: [
                _buildSosCard(context, state),
                const SizedBox(height: 22),
                const DriverGroupLabel('SHARE LOCATION'),
                const SizedBox(height: 8),
                _buildShareLocation(state),
                const SizedBox(height: 22),
                const DriverGroupLabel('REPORT A PROBLEM'),
                const SizedBox(height: 8),
                _buildReportSection(context, state),
                const SizedBox(height: 22),
                const DriverGroupLabel('EMERGENCY CONTACTS'),
                const SizedBox(height: 8),
                _buildContacts(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSosCard(BuildContext context, DriverState state) {
    final sentAt = state.sosSentAt;

    if (sentAt != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DriverTheme.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: DriverTheme.danger.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.sos_rounded,
              color: DriverTheme.danger,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              'SOS sent at ${DriverTheme.formatTime(sentAt)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: DriverTheme.danger,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Admin, the terminal and your emergency contacts can see '
              'your live location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: DriverTheme.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: state.cancelSos,
              style: OutlinedButton.styleFrom(
                foregroundColor: DriverTheme.danger,
                side: const BorderSide(color: DriverTheme.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("I'm safe: cancel SOS"),
            ),
          ],
        ),
      );
    }

    return DriverCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => showSosDialog(context),
            customBorder: const CircleBorder(),
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: DriverTheme.danger,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DriverTheme.danger.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Press SOS in an emergency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'The admin, the terminal and your emergency contacts are '
            'alerted with your live location.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DriverTheme.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildShareLocation(DriverState state) {
    return DriverCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const RoundIcon(
            icon: Icons.share_location_rounded,
            size: 40,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share live location',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'With the terminal and your emergency contacts',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: state.shareLocation,
            activeThumbColor: DriverTheme.primaryBlue,
            onChanged: state.setShareLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(BuildContext context, DriverState state) {
    final problem = state.problem;

    return Column(
      children: [
        if (problem != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DriverTheme.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: DriverTheme.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${problem.type} reported',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Passenger ETAs are +${problem.delayMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DriverTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: state.clearProblem,
                  child: const Text('Resolved'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            _ProblemTile(
              icon: Icons.build_rounded,
              label: 'Breakdown',
              onTap: () => showReportProblemSheet(context, initialType: 0),
            ),
            const SizedBox(width: 10),
            _ProblemTile(
              icon: Icons.schedule_rounded,
              label: 'Delay',
              onTap: () => showReportProblemSheet(context, initialType: 1),
            ),
            const SizedBox(width: 10),
            _ProblemTile(
              icon: Icons.report_problem_rounded,
              label: 'Incident',
              onTap: () => showReportProblemSheet(context, initialType: 2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContacts(BuildContext context, DriverState state) {
    final contacts = state.contacts;

    return Column(
      children: [
        for (var i = 0; i < contacts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DriverCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const RoundIcon(icon: Icons.person_rounded, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contacts[i].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contacts[i].phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove contact',
                    onPressed: () => state.removeContact(i),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _addContact(context, state),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Add emergency contact',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: DriverTheme.primaryBlue,
              side: BorderSide(
                color: DriverTheme.primaryBlue.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addContact(BuildContext context, DriverState state) async {
    final contact = await showDialog<EmergencyContact>(
      context: context,
      builder: (_) => const _AddContactDialog(),
    );

    if (!context.mounted || contact == null) return;

    state.addContact(contact);
  }
}

class _ProblemTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProblemTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DriverTheme.primaryBlue.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                RoundIcon(icon: icon),
                const SizedBox(height: 9),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  const _AddContactDialog();

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    Navigator.pop(
      context,
      EmergencyContact(name: name, phone: phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add emergency contact',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: DriverTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}