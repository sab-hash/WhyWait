import 'package:flutter/material.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _pickupController = TextEditingController(text: 'Current location');
  final _destinationController = TextEditingController();
  final _stopController = TextEditingController();

  String _vehicleType = 'Standard';
  bool _multiStop = false;
  bool _scheduled = false;
  DateTime? _scheduledTime;

  static const _vehicleTypes = ['Standard', 'Comfort', 'Van', 'Bajaj'];

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _stopController.dispose();
    super.dispose();
  }

  bool get _canRequest =>
      _destinationController.text.trim().isNotEmpty;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickScheduleTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime ?? now),
    );
    if (time == null) return;
    setState(() {
      _scheduledTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _onRequestRide() {
    if (!_canRequest) {
      _showMessage('Please enter a destination');
      return;
    }
    // TODO: navigate to FindingDriverScreen when we build it.
    _showMessage('Searching for a driver...');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Ride'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _pickupField(),
            const SizedBox(height: 12),
            _destinationField(),
            const SizedBox(height: 12),
            _multiStopToggle(),
            if (_multiStop) ...[
              const SizedBox(height: 8),
              _stopField(),
            ],
            const SizedBox(height: 20),
            Text('Vehicle type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _vehicleTypeRow(),
            const SizedBox(height: 20),
            _scheduleToggle(),
            if (_scheduled) ...[
              const SizedBox(height: 8),
              _scheduledTimeTile(),
            ],
            const SizedBox(height: 24),
            _fareEstimateCard(),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _canRequest ? _onRequestRide : null,
                child: const Text('Request Ride'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _pickupField() {
    return TextField(
      controller: _pickupController,
      decoration: const InputDecoration(
        labelText: 'Pickup',
        prefixIcon: Icon(Icons.my_location),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _destinationField() {
    return TextField(
      controller: _destinationController,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        labelText: 'Destination',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _stopField() {
    return TextField(
      controller: _stopController,
      decoration: const InputDecoration(
        labelText: 'Stop',
        prefixIcon: Icon(Icons.add_location_alt),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _multiStopToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Add a stop'),
      value: _multiStop,
      onChanged: (value) => setState(() => _multiStop = value),
    );
  }

  Widget _vehicleTypeRow() {
    return Wrap(
      spacing: 8,
      children: _vehicleTypes.map((type) {
        final selected = _vehicleType == type;
        return ChoiceChip(
          label: Text(type),
          selected: selected,
          onSelected: (_) => setState(() => _vehicleType = type),
        );
      }).toList(),
    );
  }

  Widget _scheduleToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Schedule for later'),
      value: _scheduled,
      onChanged: (value) => setState(() => _scheduled = value),
    );
  }

  Widget _scheduledTimeTile() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(
          _scheduledTime == null
              ? 'Pick a time'
              : _scheduledTime!.toString().substring(0, 16),
        ),
        trailing: const Icon(Icons.edit),
        onTap: _pickScheduleTime,
      ),
    );
  }

  Widget _fareEstimateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated fare',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _fareRow('Distance', '8.2 km'),
            const SizedBox(height: 6),
            _fareRow('ETA', '24 min'),
            const SizedBox(height: 6),
            _fareRow('Wait', '4 min'),
            const Divider(height: 24),
            _fareRow('Total', '85 ETB', bold: true),
          ],
        ),
      ),
    );
  }

  Widget _fareRow(String label, String value, {bool bold = false}) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : const TextStyle(fontSize: 14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}