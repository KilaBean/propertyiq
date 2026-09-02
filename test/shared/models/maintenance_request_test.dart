import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:propertyiq/shared/models/maintenance_category.dart';
import 'package:propertyiq/shared/models/maintenance_priority.dart';
import 'package:propertyiq/shared/models/maintenance_request.dart';
import 'package:propertyiq/shared/models/maintenance_status.dart';

void main() {
  group('MaintenanceRequest JSON', () {
    test('maps columns, enums and in_progress status', () {
      final r = MaintenanceRequest.fromJson({
        'id': 'm1',
        'unit_id': 'u1',
        'tenant_id': 't1',
        'title': 'Leaking tap',
        'description': 'Kitchen sink drips',
        'category': 'plumbing',
        'priority': 'high',
        'status': 'in_progress',
        'ai_recommendation': 'Inspect the tap washer.',
        'ai_generated': true,
      });

      expect(r.unitId, 'u1');
      expect(r.category, MaintenanceCategory.plumbing);
      expect(r.priority, MaintenancePriority.high);
      expect(r.status, MaintenanceStatus.inProgress);
      expect(r.aiGenerated, isTrue);
    });

    test('defaults when fields absent', () {
      final r = MaintenanceRequest.fromJson({
        'id': 'm2',
        'unit_id': 'u1',
        'tenant_id': 't1',
        'title': 'X',
      });
      expect(r.category, MaintenanceCategory.other);
      expect(r.priority, MaintenancePriority.medium);
      expect(r.status, MaintenanceStatus.open);
      expect(r.aiGenerated, isFalse);
    });

    test('status.value maps inProgress to the DB token', () {
      expect(MaintenanceStatus.inProgress.value, 'in_progress');
      expect(MaintenanceStatus.open.value, 'open');
    });
  });

  group('MaintenanceTriage.fromJson', () {
    test('parses an AI result', () {
      final t = MaintenanceTriage.fromJson({
        'category': 'electrical',
        'priority': 'urgent',
        'recommendation': 'Do not touch exposed wiring.',
        'ai_generated': true,
      });
      expect(t.category, MaintenanceCategory.electrical);
      expect(t.priority, MaintenancePriority.urgent);
      expect(t.aiGenerated, isTrue);
    });

    test('falls back safely on unknown values', () {
      final t = MaintenanceTriage.fromJson({
        'category': 'made_up',
        'priority': null,
        'recommendation': 'Team will review.',
        'ai_generated': false,
      });
      expect(t.category, MaintenanceCategory.other);
      expect(t.priority, MaintenancePriority.medium);
      expect(t.aiGenerated, isFalse);
    });
  });
}
