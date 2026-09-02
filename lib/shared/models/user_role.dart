import 'package:json_annotation/json_annotation.dart';

/// App-level role. Mirrors the `public.user_role` Postgres enum and is the
/// value RLS + the router both branch on.
enum UserRole {
  @JsonValue('manager')
  manager,
  @JsonValue('tenant')
  tenant;

  bool get isManager => this == UserRole.manager;
  bool get isTenant => this == UserRole.tenant;
}
