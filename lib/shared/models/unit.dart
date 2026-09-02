import 'package:freezed_annotation/freezed_annotation.dart';

import 'unit_status.dart';

part 'unit.freezed.dart';
part 'unit.g.dart';

/// A rentable unit within a property. Mirrors `public.units`.
@freezed
abstract class Unit with _$Unit {
  const factory Unit({
    required String id,
    @JsonKey(name: 'property_id') required String propertyId,
    required String label,
    @Default(0) int bedrooms,
    @JsonKey(name: 'base_rent') @Default(0) num baseRent,
    @Default(UnitStatus.vacant) UnitStatus status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
