import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkText = Color(0xFF333333);

  String? selectedIssue;
  String? selectedTrip;
  String selectedReportFilter = 'All';

  int selectedRating = 0;

  bool showValidation = false;
  bool isSubmitting = false;

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController vehicleController =
      TextEditingController();

  final TextEditingController feedbackController =
      TextEditingController();

  final List<String> issueTypes = [
    'Driver behavior',
    'Fare issue',
    'Wrong route',
    'Safety problem',
    'Vehicle problem',
    'Other',
  ];

  final List<String> recentTrips = [
    'Bole → Mexico',
    'Piazza → Bole',
    'Megenagna → Piazza',
    'Mexico → Bole',
  ];

  final List<String> reportFilters = [
    'All',
    'Pending',
    'Reviewed',
    'Resolved',
  ];

  final List<Map<String, String>> reports = [
    {
      'issue': 'Driver behavior',
      'trip': 'Bole → Mexico',
      'date': '18 Aug 2026',
      'status': 'Reviewed',
    },
    {
      'issue': 'Fare issue',
      'trip': 'Piazza → Bole',
      'date': '16 Aug 2026',
      'status': 'Pending',
    },
    {
      'issue': 'Vehicle problem',
      'trip': 'Mexico → Bole',
      'date': '12 Aug 2026',
      'status': 'Resolved',
    },
  ];

  bool get isFormValid {
    return selectedTrip != null &&
        selectedIssue != null &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    vehicleController.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Report an Issue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.report_problem_outlined,
            color: primaryBlue,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help us improve your trip',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tell us about any problem you experienced during your trip.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Which trip?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select the trip you want to report.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: showValidation && selectedTrip == null
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedTrip,
              isExpanded: true,
              hint: const Text(
                'Select a recent trip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primaryBlue,
              ),
              items: recentTrips.map((trip) {
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
              onChanged: (value) {
                setState(() {
                  selectedTrip = value;
                });
              },
            ),
          ),
        ),
        if (showValidation && selectedTrip == null)
          Padding(
            padding: const EdgeInsets.only(
              top: 6,
              left: 4,
            ),
            child: Text(
              'Please select a trip',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIssueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What happened?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select one issue that best describes your experience.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showValidation && selectedIssue == null
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < issueTypes.length; i++)
                _buildIssueOption(
                  issueTypes[i],
                  i == issueTypes.length - 1,
                ),
            ],
          ),
        ),
        if (showValidation && selectedIssue == null)
          Padding(
            padding: const EdgeInsets.only(
              top: 6,
              left: 4,
            ),
            child: Text(
              'Please select an issue',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIssueOption(
    String issue,
    bool isLast,
  ) {
    final bool isSelected = selectedIssue == issue;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              selectedIssue = issue;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: isSelected ? lightBlue : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: issue == issueTypes.first
                    ? const Radius.circular(16)
                    : Radius.zero,
                bottom: isLast
                    ? const Radius.circular(16)
                    : Radius.zero,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryBlue : lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIssueIcon(issue),
                    color: isSelected ? Colors.white : primaryBlue,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    issue,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: darkText,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? primaryBlue
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 71,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
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

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver or vehicle details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Optional information that can help us identify the trip.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: vehicleController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText:
                  'Driver name, plate number, or vehicle details',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.local_taxi_outlined,
                color: primaryBlue,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 17,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final bool hasText =
        descriptionController.text.trim().isNotEmpty;

    final int characterCount =
        descriptionController.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Give us more details about what happened.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showValidation && !hasText
                  ? Colors.red.shade300
                  : hasText
                      ? primaryBlue
                      : Colors.grey.shade200,
              width:
                  showValidation && !hasText || hasText ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: 6,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              setState(() {
                showValidation = false;
              });
            },
            decoration: InputDecoration(
              hintText: 'Describe the problem...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showValidation && !hasText)
              Text(
                'Please describe the issue',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '$characterCount/500',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate your trip',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'How was your overall experience?',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) {
                    final int rating = index + 1;
                    final bool isSelected =
                        rating <= selectedRating;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = rating;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration:
                              const Duration(milliseconds: 150),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 38,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedRating == 0
                    ? 'Tap a star to rate your trip'
                    : _getRatingText(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selectedRating == 0
                      ? FontWeight.normal
                      : FontWeight.bold,
                  color: selectedRating == 0
                      ? Colors.grey.shade500
                      : primaryBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: feedbackController,
            maxLines: 3,
            maxLength: 300,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Additional feedback (optional)',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 8,
                  bottom: 55,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${feedbackController.text.length}/300',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText() {
    switch (selectedRating) {
      case 1:
        return 'Very poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = isFormValid;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : canSubmit
                    ? _handleSubmit
                    : () {
                        FocusScope.of(context).unfocus();

                        setState(() {
                          showValidation = true;
                        });
                      },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    canSubmit
                        ? 'Submit Report'
                        : 'Complete the Form',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canSubmit
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
          ),
        ),
        if (showValidation && !canSubmit) ...[
          const SizedBox(height: 10),
          Text(
            'Please complete the required fields before submitting.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReportsSection() {
    final List<Map<String, String>> filteredReports =
        selectedReportFilter == 'All'
            ? reports
            : reports.where((report) {
                return report['status'] ==
                    selectedReportFilter;
              }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MY REPORTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${filteredReports.length} reports',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildReportFilters(),
        const SizedBox(height: 16),
        if (filteredReports.isEmpty)
          _buildFilteredEmptyState()
        else
          Column(
            children: filteredReports.map((report) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: _buildReportCard(report),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReportFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: reportFilters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final String filter = reportFilters[index];
          final bool isSelected =
              selectedReportFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedReportFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryBlue
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? primaryBlue
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    String title;
    String message;
    IconData icon;

    switch (selectedReportFilter) {
      case 'Pending':
        title = 'No pending reports';
        message =
            'You do not have any reports waiting for review.';
        icon = Icons.access_time_rounded;
        break;

      case 'Reviewed':
        title = 'No reviewed reports';
        message =
            'Reports reviewed by the team will appear here.';
        icon = Icons.visibility_outlined;
        break;

      case 'Resolved':
        title = 'No resolved reports';
        message =
            'Resolved reports will appear here.';
        icon = Icons.check_circle_outline_rounded;
        break;

      default:
        title = 'No reports yet';
        message =
            'Your submitted reports will appear here.';
        icon = Icons.description_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    Map<String, String> report,
  ) {
    final String status =
        report['status'] ?? 'Pending';

    return GestureDetector(
      onTap: () {
        _showReportDetails(report);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.report_problem_outlined,
                color: primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    report['issue'] ??
                        'Unknown issue',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    report['trip'] ??
                        'Unknown trip',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['date'] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    Color color;
    Color background;

    switch (status) {
      case 'Resolved':
        icon =
            Icons.check_circle_outline_rounded;
        color = Colors.green.shade700;
        background = Colors.green.shade50;
        break;

      case 'Reviewed':
        icon = Icons.visibility_outlined;
        color = primaryBlue;
        background = lightBlue;
        break;

      default:
        icon = Icons.access_time_rounded;
        color = Colors.orange.shade700;
        background = Colors.orange.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(
    Map<String, String> report,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      report['issue'] ?? '',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _detailRow(
                'Trip',
                report['trip'] ?? '',
              ),
              const SizedBox(height: 13),
              _detailRow(
                'Date',
                report['date'] ?? '',
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildStatusBadge(
                    report['status'] ??
                        'Pending',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    FocusScope.of(context).unfocus();

    setState(() {
      showValidation = true;
    });

    if (!isFormValid) {
      return;
    }

    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: primaryBlue,
              ),
              SizedBox(width: 10),
              Text(
                'Submit report?',
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _confirmationRow(
                'Trip',
                selectedTrip!,
              ),
              const SizedBox(height: 10),
              _confirmationRow(
                'Issue',
                selectedIssue!,
              ),
              const SizedBox(height: 10),
              _confirmationRow(
                'Description',
                descriptionController.text.trim(),
              ),
              if (vehicleController.text
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(height: 10),
                _confirmationRow(
                  'Details',
                  vehicleController.text.trim(),
                ),
              ],
              if (selectedRating > 0) ...[
                const SizedBox(height: 10),
                _confirmationRow(
                  'Rating',
                  '$selectedRating/5 - ${_getRatingText()}',
                ),
              ],
              if (feedbackController.text
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(height: 10),
                _confirmationRow(
                  'Feedback',
                  feedbackController.text.trim(),
                ),
              ],
            ],
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            18,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _submitReport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _confirmationRow(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    setState(() {
      isSubmitting = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) {
      return;
    }

    final Map<String, String> newReport = {
      'issue': selectedIssue!,
      'trip': selectedTrip!,
      'date': '20 Aug 2026',
      'status': 'Pending',
    };

    setState(() {
      reports.insert(0, newReport);
      isSubmitting = false;
    });

    _clearForm();

    _showSuccessDialog();
  }

  void _clearForm() {
    setState(() {
      selectedIssue = null;
      selectedTrip = null;
      descriptionController.clear();
      vehicleController.clear();
      feedbackController.clear();
      selectedRating = 0;
      showValidation = false;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: primaryBlue,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Report Submitted',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you for helping us improve the WhyWait experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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