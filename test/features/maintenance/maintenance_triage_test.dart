import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:propertyiq/shared/models/maintenance_category.dart';
import 'package:propertyiq/shared/models/maintenance_priority.dart';

/// The triage payload comes back from a model. The Edge Function constrains it
/// with a response schema, but the client is the last line of defence: an
/// unexpected value must degrade to a safe default rather than throw and lose
/// the tenant's request.
void main() {
  group('MaintenanceTriage.fromJson', () {
    test('maps a well-formed response', () {
      final t = MaintenanceTriage.fromJson(const {
        'category': 'electrical',
        'priority': 'urgent',
        'recommendation': 'Isolate the circuit before inspection.',
        'ai_generated': true,
      });

      expect(t.category, MaintenanceCategory.electrical);
      expect(t.priority, MaintenancePriority.urgent);
      expect(t.recommendation, 'Isolate the circuit before inspection.');
      expect(t.aiGenerated, isTrue);
    });

    test('falls back to other/medium on unrecognised values', () {
      final t = MaintenanceTriage.fromJson(const {
        'category': 'teleportation',
        'priority': 'catastrophic',
        'recommendation': '',
        'ai_generated': false,
      });

      expect(t.category, MaintenanceCategory.other);
      expect(t.priority, MaintenancePriority.medium);
    });

    test('tolerates missing fields', () {
      final t = MaintenanceTriage.fromJson(const {});

      expect(t.category, MaintenanceCategory.other);
      expect(t.priority, MaintenancePriority.medium);
      expect(t.recommendation, '');
      expect(t.aiGenerated, isFalse);
    });

    test('treats a non-true ai_generated as false', () {
      // The function returns the literal `false` on its fallback path; anything
      // other than a real `true` must not be presented to the manager as an AI
      // assessment.
      for (final value in [false, null, 'true', 1]) {
        final t = MaintenanceTriage.fromJson({
          'category': 'plumbing',
          'priority': 'low',
          'recommendation': 'x',
          'ai_generated': value,
        });
        expect(t.aiGenerated, isFalse, reason: 'for $value');
      }
    });
  });
}
