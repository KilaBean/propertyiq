import 'package:json_annotation/json_annotation.dart';

/// Mirrors `public.maintenance_category`. Also set by the AI triage function.
enum MaintenanceCategory {
  @JsonValue('plumbing')
  plumbing,
  @JsonValue('electrical')
  electrical,
  @JsonValue('structural')
  structural,
  @JsonValue('hvac')
  hvac,
  @JsonValue('appliance')
  appliance,
  @JsonValue('pest')
  pest,
  @JsonValue('other')
  other;

  String get label => switch (this) {
        MaintenanceCategory.plumbing => 'Plumbing',
        MaintenanceCategory.electrical => 'Electrical',
        MaintenanceCategory.structural => 'Structural',
        MaintenanceCategory.hvac => 'HVAC',
        MaintenanceCategory.appliance => 'Appliance',
        MaintenanceCategory.pest => 'Pest',
        MaintenanceCategory.other => 'Other',
      };

  /// Maps a raw enum name (e.g. from the triage function) to a value, defaulting
  /// to [other] for anything unexpected.
  static MaintenanceCategory fromName(String? name) =>
      MaintenanceCategory.values.firstWhere(
        (e) => e.name == name,
        orElse: () => MaintenanceCategory.other,
      );
}
