import 'package:json_annotation/json_annotation.dart';

/// Mirrors the `public.unit_status` Postgres enum.
enum UnitStatus {
  @JsonValue('vacant')
  vacant,
  @JsonValue('occupied')
  occupied;

  String get label => switch (this) {
        UnitStatus.vacant => 'Vacant',
        UnitStatus.occupied => 'Occupied',
      };
}
