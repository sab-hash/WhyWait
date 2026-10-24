import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/local_storage.dart';
import '../../services/grpc_client.dart';
import '../../generated/whywait.pb.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  // ---- Reports ----
  List<ReportInfo> _reports = [];
  bool _isLoadingReports = true;
  String _filterStatus = '';

  // ---- Stats ----
  AdminStatsResponse? _stats;

  // ---- Register Taxi Form ----
  final _formKey = GlobalKey<FormState>();
  final _driverNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  String? _selectedTerminalAId;
  String? _selectedTerminalBId;
  List<Terminal> _terminals = [];
  bool _isRegistering = false;

  // ---- Taxi Routes ----
  List<TaxiRouteInfo> _taxiRoutes = [];
  bool _isLoadingRoutes = true;

  // ---- Animation ----
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTerminals();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _vehiclePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================
  Future<void> _loadData() async {
    setState(() {
      _isLoadingReports = true;
      _isLoadingRoutes = true;
    });
    try {
      final statsFuture = GrpcClient().getAdminStats();
      final reportsFuture = GrpcClient().getReports(status: _filterStatus, limit: 100);
      final routesFuture = GrpcClient().getTaxiRoutes();

      final results = await Future.wait([statsFuture, reportsFuture, routesFuture]);
      if (!mounted) return;
      
      setState(() {
        _stats = results[0] as AdminStatsResponse;
        _reports = (results[1] as GetReportsResponse).reports;
        _taxiRoutes = (results[2] as TaxiRoutesResponse).taxis;
        _isLoadingReports = false;
        _isLoadingRoutes = false;
      });
    } catch (e) {
      debugPrint('Error loading admin data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingReports = false;
        _isLoadingRoutes = false;
      });
    }
  }

  Future<void> _loadTerminals() async {
    try {
      final response = await GrpcClient().getTerminals();
      if (!mounted) return;
      setState(() {
        _terminals = response.terminals;
      });
    } catch (e) {
      debugPrint('Error loading terminals: $e');
    }
  }

  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    try {
      await GrpcClient().updateReportStatus(reportId, newStatus);
      _loadData(); // refresh
    } catch (e) {
      _showSnackbar('Error updating status: $e', Colors.red);
    }
  }

  // ============================================================
  // REGISTER TAXI & DRIVER
  // ============================================================
  Future<void> _registerTaxiDriver() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTerminalAId == null || _selectedTerminalBId == null) {
      _showSnackbar('Please select both terminals', Colors.orange);
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final response = await GrpcClient().registerTaxiDriver(
        driverName: _driverNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        vehiclePlate: _vehiclePlateController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        vehicleColor: _vehicleColorController.text.trim(),
        terminalAId: _selectedTerminalAId!,
        terminalBId: _selectedTerminalBId!,
      );

      if (response.success) {
        _showSuccessDialog();
        _clearForm();
        _loadData(); // refresh routes
      } else {
        _showSnackbar('❌ Registration failed: ${response.message}', Colors.red);
      }
    } catch (e) {
      _showSnackbar('❌ Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green, Colors.greenAccent]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              const Text(
                'Registration Successful! 🎉',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Taxi and driver have been registered.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearForm() {
    _driverNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _vehiclePlateController.clear();
    _vehicleModelController.clear();
    _vehicleColorController.clear();
    _selectedTerminalAId = null;
    _selectedTerminalBId = null;
    _formKey.currentState?.reset();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LocalStorage.clearAll();
      if (!mounted) return;
      context.go('/login');
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabs(),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildReportsTab(),
                  _buildRegisterTaxiTab(),
                  _buildRoutesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _selectedTab = 1),
        icon: const Icon(Icons.directions_car),
        label: const Text('Register Taxi'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _tabButton('Reports', 0),
          _tabButton('Register Taxi', 1),
          _tabButton('Routes', 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1565C0) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAB 1: REPORTS
  // ============================================================
  Widget _buildReportsTab() {
    return Column(
      children: [
        if (_stats != null) _buildStatsRow(),
        const SizedBox(height: 8),
        _buildFilterTabs(),
        Expanded(
          child: _isLoadingReports
              ? const Center(child: CircularProgressIndicator())
              : _reports.isEmpty
                  ? const Center(child: Text('No reports found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        return _buildReportCard(_reports[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _statCard('Total', _stats!.totalReports, Colors.blue),
          _statCard('Pending', _stats!.pendingReports, Colors.orange),
          _statCard('Reviewed', _stats!.reviewedReports, Colors.green),
          _statCard('Resolved', _stats!.resolvedReports, Colors.grey),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Pending', 'Reviewed', 'Resolved'];
    final statusMap = {'All': '', 'Pending': 'pending', 'Reviewed': 'reviewed', 'Resolved': 'resolved'};
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filterStatus == statusMap[filter];
          return GestureDetector(
            onTap: () {
              setState(() => _filterStatus = statusMap[filter]!);
              _loadData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1A6BC4)]) : null,
                color: isSelected ? null : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(ReportInfo report) {
    Color statusColor;
    switch (report.status) {
      case 'pending': statusColor = Colors.orange; break;
      case 'reviewed': statusColor = Colors.green; break;
      case 'resolved': statusColor = Colors.grey; break;
      default: statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(report.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('User: ${report.userName} (${report.userPhone})', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(report.description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Created: ${report.createdAt}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (report.status == 'pending')
                  Row(
                    children: [
                      _actionButton('Review', 'reviewed', report.id, Colors.blue),
                      const SizedBox(width: 8),
                      _actionButton('Resolve', 'resolved', report.id, Colors.green),
                    ],
                  ),
                if (report.status == 'reviewed')
                  _actionButton('Resolve', 'resolved', report.id, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, String status, String reportId, Color color) {
    return ElevatedButton(
      onPressed: () => _updateReportStatus(reportId, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // ============================================================
  // TAB 2: REGISTER TAXI & DRIVER
  // ============================================================
  Widget _buildRegisterTaxiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1A6BC4)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Register New Taxi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A))),
                        Text('Create a driver account and taxi together', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('👤 Driver Information'),
                _buildTextField(_driverNameController, 'Full Name', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),

                const SizedBox(height: 18),
                _buildSectionTitle('🚗 Vehicle Information'),
                _buildTextField(_vehiclePlateController, 'Vehicle Plate', Icons.directions_car),
                const SizedBox(height: 12),
                _buildTextField(_vehicleModelController, 'Vehicle Model', Icons.model_training),
                const SizedBox(height: 12),
                _buildTextField(_vehicleColorController, 'Vehicle Color', Icons.color_lens),

                const SizedBox(height: 18),
                _buildSectionTitle('📍 Terminal Assignment'),
                DropdownButtonFormField<String>(
                  value: _selectedTerminalAId,
                  decoration: const InputDecoration(labelText: 'Terminal A (Starting Point)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                  items: _terminals.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (value) => setState(() => _selectedTerminalAId = value),
                  validator: (value) => value == null ? 'Please select Terminal A' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTerminalBId,
                  decoration: const InputDecoration(labelText: 'Terminal B (Destination)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                  items: _terminals.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (value) => setState(() => _selectedTerminalBId = value),
                  validator: (value) => value == null ? 'Please select Terminal B' : null,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isRegistering ? null : _registerTaxiDriver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isRegistering
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Register Taxi & Driver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter $label';
        if (label == 'Phone Number' && !RegExp(r'^09\d{8}$').hasMatch(value.trim())) return 'Enter a valid phone number (09XXXXXXXX)';
        if (label == 'Email' && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) return 'Enter a valid email address';
        if (label == 'Password' && value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  // ============================================================
  // TAB 3: TAXI ROUTES
  // ============================================================
  Widget _buildRoutesTab() {
    return _isLoadingRoutes
        ? const Center(child: CircularProgressIndicator())
        : _taxiRoutes.isEmpty
            ? const Center(child: Text('No taxis registered'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _taxiRoutes.length,
                itemBuilder: (context, index) {
                  final taxi = _taxiRoutes[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: taxi.status == 'available' ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(taxi.plate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: taxi.onRoute ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  taxi.onRoute ? '✅ On Route' : '⚠️ Off Route',
                                  style: TextStyle(color: taxi.onRoute ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Driver: ${taxi.driverName}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.flag, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('A: ${taxi.terminalAName}', style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 16),
                              const Icon(Icons.flag, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('B: ${taxi.terminalBName}', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📍 (${taxi.currentLatitude.toStringAsFixed(4)}, ${taxi.currentLongitude.toStringAsFixed(4)})',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}