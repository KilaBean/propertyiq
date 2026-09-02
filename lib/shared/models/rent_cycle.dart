import 'package:json_annotation/json_annotation.dart';

/// Mirrors the `public.rent_cycle` Postgres enum.
enum RentCycle {
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly;

  String get label => switch (this) {
        RentCycle.monthly => 'Monthly',
        RentCycle.quarterly => 'Quarterly',
        RentCycle.yearly => 'Yearly',
      };
}
