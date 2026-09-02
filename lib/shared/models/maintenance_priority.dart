import 'package:json_annotation/json_annotation.dart';

/// Mirrors `public.maintenance_priority`. Also set by the AI triage function.
enum MaintenancePriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent;

  String get label => switch (this) {
        MaintenancePriority.low => 'Low',
        MaintenancePriority.medium => 'Medium',
        MaintenancePriority.high => 'High',
        MaintenancePriority.urgent => 'Urgent',
      };

  static MaintenancePriority fromName(String? name) =>
      MaintenancePriority.values.firstWhere(
        (e) => e.name == name,
        orElse: () => MaintenancePriority.medium,
      );
}
