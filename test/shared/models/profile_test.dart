import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/shared/models/profile.dart';
import 'package:propertyiq/shared/models/user_role.dart';

void main() {
  group('Profile JSON', () {
    test('maps snake_case columns and the role enum', () {
      final profile = Profile.fromJson({
        'id': 'user-1',
        'full_name': 'Jane Doe',
        'role': 'manager',
        'phone': '+233200000000',
        'created_at': '2026-06-28T10:00:00.000Z',
        'updated_at': '2026-06-28T10:00:00.000Z',
      });

      expect(profile.id, 'user-1');
      expect(profile.fullName, 'Jane Doe');
      expect(profile.role, UserRole.manager);
      expect(profile.role.isManager, isTrue);
      expect(profile.phone, '+233200000000');
      expect(profile.createdAt, isNotNull);
    });

    test('applies defaults when optional fields are absent', () {
      final profile = Profile.fromJson({'id': 'user-2', 'role': 'tenant'});

      expect(profile.fullName, '');
      expect(profile.role, UserRole.tenant);
      expect(profile.role.isTenant, isTrue);
      expect(profile.phone, isNull);
    });

    test('round-trips through toJson', () {
      const profile = Profile(
        id: 'user-3',
        fullName: 'Ama K',
        role: UserRole.tenant,
      );

      final restored = Profile.fromJson(profile.toJson());
      expect(restored, profile);
    });
  });
}
