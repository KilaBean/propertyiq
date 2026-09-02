import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_role.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// App identity for a signed-in user. Mirrors `public.profiles`.
/// Immutable; field names map to the snake_case DB columns.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'full_name') @Default('') String fullName,
    @Default(UserRole.tenant) UserRole role,
    String? phone,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
