import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/storage/local_storage.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color secondaryBlue = Color(0xFF1A6BC4);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color darkText = Color(0xFF1A2B4A);

  // ---- Form controllers ----
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  // ---- Form state ----
  String? _selectedIssue;
  String? _selectedTrip;
  int _selectedRating = 0;
  bool _showValidation = false;
  bool _isSubmitting = false;
  bool _isLoadingReports = true;

  // ---- Report history ----
  List<Map<String, dynamic>> _reports = [];
  String _selectedReportFilter = 'All';

  final List<String> _issueTypes = [
    'Driver behavior',
    'Fare issue',
    'Wrong route',
    'Safety problem',
    'Vehicle problem',
    'Other',
  ];

  final List<String> _recentTrips = [
    'Bole → Mexico',
    'Piazza → Bole',
    'Megenagna → Piazza',
    'Mexico → Bole',
  ];

  final List<String> _reportFilters = ['All', 'Pending', 'Reviewed', 'Resolved'];

  final Map<String, String> _filterDescriptions = {
    'All': 'All submitted reports',
    'Pending': 'Waiting for review',
    'Reviewed': 'Reports reviewed by the team',
    'Resolved': 'Issues that have been resolved',
  };

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD REPORTS (Real API)
  // ============================================================
  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse('http://localhost:8080/reports');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List reportsData = data['reports'] ?? [];
        setState(() {
          _reports = reportsData.map((r) => {
            'id': r['id'],
            'issue': r['type'] ?? '',
            'trip': _extractTrip(r['description']),
            'date': _formatDateString(r['created_at']),
            'status': _capitalize(r['status'] ?? 'pending'),
            'description': r['description'] ?? '',
            'vehicle': _extractVehicle(r['description']),
            'response': '',
          }).toList();
          _isLoadingReports = false;
        });
      } else {
        _showSnackbar('Failed to load reports', Colors.red);
        setState(() => _isLoadingReports = false);
      }
    } catch (e) {
      _showSnackbar('Error loading reports: $e', Colors.red);
      setState(() => _isLoadingReports = false);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  String _extractTrip(String description) {
    final match = RegExp(r'Trip: (.+)').firstMatch(description);
    return match?.group(1) ?? '';
  }

  String _extractVehicle(String description) {
    final match = RegExp(r'Vehicle: (.+)').firstMatch(description);
    return match?.group(1) ?? '';
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_monthName(date.month)} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  // ============================================================
  // SUBMIT REPORT
  // ============================================================
  Future<void> _submitReport() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty || _selectedIssue == null || _selectedTrip == null) {
      setState(() => _showValidation = true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await LocalStorage.getToken();
      final url = Uri.parse('http://localhost:8080/reports');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': _selectedIssue,
          'description': description,
          'trip': _selectedTrip,
          'vehicle': _vehicleController.text.trim(),
          'rating': _selectedRating,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
        _clearForm();
        await _loadReports();
      } else {
        _showSnackbar('Failed to submit report', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedIssue = null;
      _selectedTrip = null;
      _selectedRating = 0;
      _showValidation = false;
    });
    _descriptionController.clear();
    _vehicleController.clear();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get _isFormValid =>
      _selectedTrip != null &&
      _selectedIssue != null &&
      _descriptionController.text.trim().isNotEmpty;

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Report an Issue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 28),
            _buildTripSection(),
            const SizedBox(height: 28),
            _buildIssueSection(),
            const SizedBox(height: 28),
            _buildVehicleSection(),
            const SizedBox(height: 28),
            _buildDescriptionSection(),
            const SizedBox(height: 28),
            _buildRatingSection(),
            const SizedBox(height: 28),
            _buildSubmitButton(),
            const SizedBox(height: 36),
            _buildReportsSection(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTRO CARD
  // ============================================================
  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightBlue, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, secondaryBlue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.report_problem_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help us improve your trip',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tell us about any problem you experienced during your trip.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRIP SECTION
  // ============================================================
  Widget _buildTripSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which trip?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the trip you want to report.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _showValidation && _selectedTrip == null
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
              width: _showValidation && _selectedTrip == null ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTrip,
              isExpanded: true,
              hint: Text(
                'Select a recent trip',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primaryBlue,
              ),
              items: _recentTrips.map((trip) {
                return DropdownMenuItem<String>(
                  value: trip,
                  child: Text(
                    trip,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTrip = value),
            ),
          ),
        ),
        if (_showValidation && _selectedTrip == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please select a trip',
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // ISSUE SECTION
  // ============================================================
  Widget _buildIssueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What happened?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select one issue that best describes your experience.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _showValidation && _selectedIssue == null
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
              width: _showValidation && _selectedIssue == null ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _issueTypes.length; i++)
                _buildIssueOption(_issueTypes[i], i == _issueTypes.length - 1),
            ],
          ),
        ),
        if (_showValidation && _selectedIssue == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Please select an issue',
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildIssueOption(String issue, bool isLast) {
    final bool isSelected = _selectedIssue == issue;

    return InkWell(
      onTap: () => setState(() => _selectedIssue = issue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? lightBlue : Colors.white,
          borderRadius: BorderRadius.vertical(
            top: issue == _issueTypes.first ? const Radius.circular(14) : Radius.zero,
            bottom: isLast ? const Radius.circular(14) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [primaryBlue, secondaryBlue])
                    : null,
                color: isSelected ? null : lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIssueIcon(issue),
                color: isSelected ? Colors.white : primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                issue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? primaryBlue : darkText,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryBlue : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: primaryBlue, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIssueIcon(String issue) {
    switch (issue) {
      case 'Driver behavior':
        return Icons.person_outline_rounded;
      case 'Fare issue':
        return Icons.payments_outlined;
      case 'Wrong route':
        return Icons.route_outlined;
      case 'Safety problem':
        return Icons.shield_outlined;
      case 'Vehicle problem':
        return Icons.directions_car_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  // ============================================================
  // VEHICLE SECTION
  // ============================================================
  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver or vehicle details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional information that can help us identify the trip.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _vehicleController,
            decoration: InputDecoration(
              hintText: 'Driver name, plate number, or vehicle details',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(
                Icons.local_taxi_outlined,
                color: primaryBlue,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION SECTION
  // ============================================================
  Widget _buildDescriptionSection() {
    final bool hasText = _descriptionController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Give us more details about what happened.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _showValidation && !hasText
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
              width: _showValidation && !hasText ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Describe the problem in detail...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_showValidation && !hasText)
              Text(
                'Please describe the issue',
                style: TextStyle(fontSize: 12, color: Colors.red.shade600),
              )
            else
              const SizedBox.shrink(),
            Text(
              '${_descriptionController.text.length}/500',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // RATING SECTION
  // ============================================================
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate your trip',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How was your overall experience?',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final int rating = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = rating),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      rating <= _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      key: ValueKey(rating <= _selectedRating),
                      size: 40,
                      color: rating <= _selectedRating
                          ? Colors.amber.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () {
                setState(() => _showValidation = true);
                if (_isFormValid) {
                  _submitReport();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Submit Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // ============================================================
  // REPORTS SECTION
  // ============================================================
  Widget _buildReportsSection() {
    final filteredReports = _selectedReportFilter == 'All'
        ? _reports
        : _reports.where((r) => r['status'] == _selectedReportFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MY REPORTS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${filteredReports.length} reports',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReportFilters(),
        const SizedBox(height: 16),
        if (_isLoadingReports)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: primaryBlue),
            ),
          )
        else if (filteredReports.isEmpty)
          _buildEmptyState()
        else
          ...filteredReports.map((report) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReportCard(report),
              )),
      ],
    );
  }

  Widget _buildReportFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _reportFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _reportFilters[index];
              final isSelected = _selectedReportFilter == filter;

              return GestureDetector(
                onTap: () => setState(() => _selectedReportFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [primaryBlue, secondaryBlue])
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryBlue : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            _filterDescriptions[_selectedReportFilter] ?? '',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final String status = report['status'] ?? 'Pending';
    final Color statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () => _showReportDetails(report),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.report_problem_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['issue'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['trip'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    report['date'] ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.15), statusColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade700;
      case 'Reviewed':
        return primaryBlue;
      default:
        return Colors.orange.shade700;
    }
  }

  Widget _buildEmptyState() {
    String title, message;
    IconData icon;

    switch (_selectedReportFilter) {
      case 'Pending':
        title = 'No pending reports';
        message = 'You do not have any reports waiting for review.';
        icon = Icons.access_time_rounded;
        break;
      case 'Reviewed':
        title = 'No reviewed reports';
        message = 'Reviewed reports will appear here.';
        icon = Icons.visibility_outlined;
        break;
      case 'Resolved':
        title = 'No resolved reports';
        message = 'Resolved reports will appear here.';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        title = 'No reports yet';
        message = 'Your submitted reports will appear here.';
        icon = Icons.description_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT DETAILS BOTTOM SHEET
  // ============================================================
  void _showReportDetails(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryBlue, secondaryBlue],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.report_problem_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            report['issue'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        _buildStatusBadge(report['status'] ?? 'Pending'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem('Trip', report['trip'] ?? ''),
                    _buildDetailItem('Date', report['date'] ?? ''),
                    _buildDetailItem('Vehicle', report['vehicle'] ?? ''),
                    const SizedBox(height: 16),
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        report['description'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    if ((report['response'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'TEAM RESPONSE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryBlue.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.support_agent_rounded,
                              color: primaryBlue,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                report['response'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$title:',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Report Submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your report has been submitted and is now pending review.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}