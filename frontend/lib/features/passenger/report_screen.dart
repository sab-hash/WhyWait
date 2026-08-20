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

  final TextEditingController descriptionController =
      TextEditingController();

  final List<String> issueTypes = [
    'Driver behavior',
    'Fare issue',
    'Wrong route',
    'Safety problem',
    'Vehicle problem',
    'Other',
  ];

  @override
  void dispose() {
    descriptionController.dispose();
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
            _buildIssueSection(),
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
              color: Colors.grey.shade200,
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
      ],
    );
  }

  Widget _buildIssueOption(String issue, bool isLast) {
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
                    borderRadius: BorderRadius.circular(12),
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

  Widget _buildDescriptionSection() {
    final bool hasText =
        descriptionController.text.trim().isNotEmpty;

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
              color: hasText
                  ? primaryBlue
                  : Colors.grey.shade200,
              width: hasText ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: descriptionController,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Describe the problem...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        if (hasText)
          Padding(
            padding: const EdgeInsets.only(
              top: 6,
              left: 4,
            ),
            child: Text(
              '${descriptionController.text.length} characters',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit =
        selectedIssue != null &&
        descriptionController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canSubmit ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Submit Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: canSubmit
                ? Colors.white
                : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}