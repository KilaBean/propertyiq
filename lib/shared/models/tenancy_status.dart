import 'package:json_annotation/json_annotation.dart';

/// Mirrors the `public.tenancy_status` Postgres enum.
enum TenancyStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('ended')
  ended;

  String get label => switch (this) {
        TenancyStatus.pending => 'Pending',
        TenancyStatus.active => 'Active',
        TenancyStatus.ended => 'Ended',
      };
}
