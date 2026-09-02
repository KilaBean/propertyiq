import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/models/maintenance_priority.dart';
import '../../../../shared/models/maintenance_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final MaintenanceStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      MaintenanceStatus.open => StatusTone.warning,
      MaintenanceStatus.inProgress => StatusTone.info,
      MaintenanceStatus.resolved => StatusTone.success,
    };
    return StatusBadge(label: status.label, tone: tone);
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final MaintenancePriority priority;

  @override
  Widget build(BuildContext context) {
    final tone = switch (priority) {
      MaintenancePriority.urgent => StatusTone.danger,
      MaintenancePriority.high => StatusTone.warning,
      MaintenancePriority.medium => StatusTone.info,
      MaintenancePriority.low => StatusTone.neutral,
    };
    return StatusBadge(label: priority.label, tone: tone, dot: false);
  }
}
