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