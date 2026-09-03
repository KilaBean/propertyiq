import 'package:freezed_annotation/freezed_annotation.dart';

part 'property.freezed.dart';
part 'property.g.dart';

/// A manager-owned property. Mirrors `public.properties`.
@freezed
abstract class Property with _$Property {
  const factory Property({
    required String id,
    @JsonKey(name: 'manager_id') required String managerId,
    required String name,
    String? address,
    @Default('GHS') String currency,
    @JsonKey(name: 'photo_path') String? photoPath,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Property;

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
}
