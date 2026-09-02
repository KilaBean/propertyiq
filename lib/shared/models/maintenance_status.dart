import 'package:json_annotation/json_annotation.dart';

/// Mirrors `public.maintenance_status`.
enum MaintenanceStatus {
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved;

  String get label => switch (this) {
        MaintenanceStatus.open => 'Open',
        MaintenanceStatus.inProgress => 'In progress',
        MaintenanceStatus.resolved => 'Resolved',
      };

  /// The Postgres enum value (note: `inProgress` maps to `in_progress`).
  String get value => switch (this) {
        MaintenanceStatus.open => 'open',
        MaintenanceStatus.inProgress => 'in_progress',
        MaintenanceStatus.resolved => 'resolved',
      };
}
