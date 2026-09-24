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

/// An icon, a value, and a label arranged vertically.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: DriverTheme.primaryBlue,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Vertical divider for statistic groups.
class StatDivider extends StatelessWidget {
  final double height;

  const StatDivider({
    super.key,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      color: DriverTheme.divider,
    );
  }
}

/// Round tinted icon used by quick actions and summaries.
class RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const RoundIcon({
    super.key,
    required this.icon,
    this.color = DriverTheme.primaryBlue,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }
}

/// Row card used by profile settings and navigation options.
class DriverRowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color color;

  const DriverRowTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.color = DriverTheme.deepBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented tabs used by the driver history screen.
class DriverSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DriverSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = selectedIndex.clamp(0, labels.length - 1);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == safeIndex;

          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: labels[index],
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? DriverTheme.primaryBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : DriverTheme.textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Bottom navigation for Home, Map, History, and Profile.
class DriverBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DriverBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<(IconData, String)> _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.map_rounded, 'Map'),
    (Icons.history_rounded, 'History'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, _items.length - 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final selected = index == safeIndex;
              final color =
                  selected ? DriverTheme.primaryBlue : Colors.grey;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: _items[index].$2,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _items[index].$1,
                            color: color,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _items[index].$2,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
        ),
      ),
    );
  }
}