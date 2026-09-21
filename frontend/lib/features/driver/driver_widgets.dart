import 'package:flutter/material.dart';

import '../../models/driver_models.dart';
import 'driver_theme.dart';

/// Returns the color associated with a document status.
Color docStatusColor(DocStatus status) {
  switch (status) {
    case DocStatus.verified:
      return DriverTheme.success;
    case DocStatus.pending:
      return DriverTheme.primaryBlue;
    case DocStatus.expiring:
      return DriverTheme.warning;
    case DocStatus.expired:
    case DocStatus.missing:
      return DriverTheme.danger;
  }
}

/// Returns the icon associated with a document status.
IconData docStatusIcon(DocStatus status) {
  switch (status) {
    case DocStatus.verified:
      return Icons.check_circle_rounded;
    case DocStatus.pending:
      return Icons.hourglass_bottom_rounded;
    case DocStatus.expiring:
      return Icons.schedule_rounded;
    case DocStatus.expired:
      return Icons.error_rounded;
    case DocStatus.missing:
      return Icons.upload_file_rounded;
  }
}

/// Blue app bar used by driver sub-screens.
PreferredSizeWidget buildDriverAppBar(
  String title, {
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: DriverTheme.primaryBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: showBack,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: actions,
  );
}
/// Displays a floating message to the user.
void showDriverSnack(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? DriverTheme.danger : DriverTheme.textDark,
      ),
    );
}
/// White rounded card with a soft shadow.
class DriverCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const DriverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: DriverTheme.cardDecoration(),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}
/// Section heading with an optional trailing widget.
class DriverSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const DriverSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small grey label above a group of cards.
class DriverGroupLabel extends StatelessWidget {
  final String text;

  const DriverGroupLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }
}
/// Rounded pill with a colored label and optional icon.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}