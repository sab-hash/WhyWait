import 'package:flutter/material.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkText = Color(0xFF333333);

  final _pickupController = TextEditingController(text: 'Current location');
  final _destinationController = TextEditingController();
  final _stopController = TextEditingController();

  String _vehicleType = 'Taxi';
  bool _multiStop = false;
  bool _scheduled = false;
  DateTime? _scheduledTime;

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _stopController.dispose();
    super.dispose();
  }

  bool get _canRequest => _destinationController.text.trim().isNotEmpty;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
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
    _showMessage('Searching for a $_vehicleType...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request a Ride',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(),
              const SizedBox(height: 20),
              _sectionLabel('VEHICLE TYPE'),
              const SizedBox(height: 10),
              _vehicleTypeRow(),
              const SizedBox(height: 20),
              _multiStopToggle(),
              if (_multiStop) ...[
                const SizedBox(height: 8),
                _stopField(),
              ],
              const SizedBox(height: 8),
              _scheduleToggle(),
              if (_scheduled) ...[
                const SizedBox(height: 8),
                _scheduledTimeTile(),
              ],
              const SizedBox(height: 24),
              _fareEstimateCard(),
              const SizedBox(height: 20),
              _buildRequestButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _pickupController,
            label: 'Pickup',
            icon: Icons.my_location,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _destinationController,
            label: 'Destination',
            icon: Icons.place,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        color: darkText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: primaryBlue, size: 22),
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _stopField() {
    return _buildTextField(
      controller: _stopController,
      label: 'Stop',
      icon: Icons.add_location_alt,
    );
  }

  Widget _vehicleTypeRow() {
    return Row(
      children: [
        Expanded(
          child: _vehicleCard(
            type: 'Taxi',
            icon: Icons.local_taxi_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _vehicleCard(
            type: 'Bus',
            icon: Icons.directions_bus_rounded,
          ),
        ),
      ],
    );
  }

  Widget _vehicleCard({required String type, required IconData icon}) {
    final selected = _vehicleType == type;
    return GestureDetector(
      onTap: () => setState(() => _vehicleType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primaryBlue : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? primaryBlue.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : primaryBlue,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _multiStopToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Text(
          'Add a stop',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        activeThumbColor: primaryBlue,
        value: _multiStop,
        onChanged: (value) => setState(() => _multiStop = value),
      ),
    );
  }

  Widget _scheduleToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Text(
          'Schedule for later',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        activeThumbColor: primaryBlue,
        value: _scheduled,
        onChanged: (value) => setState(() => _scheduled = value),
      ),
    );
  }

  Widget _scheduledTimeTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: primaryBlue),
        title: Text(
          _scheduledTime == null
              ? 'Pick a time'
              : _scheduledTime!.toString().substring(0, 16),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        trailing: const Icon(Icons.edit, color: primaryBlue),
        onTap: _pickScheduleTime,
      ),
    );
  }

  Widget _fareEstimateCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMATED FARE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          _fareRow('Distance', '8.2 km'),
          const SizedBox(height: 8),
          _fareRow('ETA', '24 min'),
          const SizedBox(height: 8),
          _fareRow('Wait', '4 min'),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _vehicleType == 'Bus' ? '25 ETB' : '85 ETB',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canRequest ? _onRequestRide : null,
        icon: const Icon(Icons.local_taxi_rounded),
        label: const Text(
          'Request Ride',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}