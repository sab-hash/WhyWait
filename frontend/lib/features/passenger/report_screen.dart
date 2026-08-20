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

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController vehicleController =
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

  bool showValidation = false;

  @override
  void dispose() {
    descriptionController.dispose();
    vehicleController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    return selectedIssue != null &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
            _buildSubmitButton(),
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
              showValidation = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? lightBlue
                  : Colors.white,
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
                    color: isSelected
                        ? primaryBlue
                        : lightBlue,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIssueIcon(issue),
                    color: isSelected
                        ? Colors.white
                        : primaryBlue,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    issue,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: darkText,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? primaryBlue
                        : Colors.grey.shade400,
                    size: 22,
                  ),
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
              contentPadding:
                  const EdgeInsets.symmetric(
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
              color: showValidation &&
                      !hasText
                  ? Colors.red.shade300
                  : hasText
                      ? primaryBlue
                      : Colors.grey.shade200,
              width: showValidation &&
                          !hasText ||
                      hasText
                  ? 1.5
                  : 1,
            ),
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: 6,
            maxLength: 500,
            textInputAction:
                TextInputAction.newline,
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
              contentPadding:
                  const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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

  Widget _buildSubmitButton() {
    final bool canSubmit = isFormValid;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
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
    );
  }

  void _handleSubmit() {
    setState(() {
      showValidation = true;
    });

    if (!isFormValid) {
      return;
    }
  }
}