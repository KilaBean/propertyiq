import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../../shared/models/unit.dart';
import '../../../../shared/models/unit_status.dart';

part 'unit_repository.g.dart';

/// Data access for `units`. RLS scopes every row to units inside a property
/// the signed-in manager owns.
class UnitRepository {
  UnitRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'units';

  Stream<List<Unit>> watchByProperty(String propertyId) => _client
      .from(_table)
      .stream(primaryKey: ['id'])
      .eq('property_id', propertyId)
      .order('label')
      .map((rows) => rows.map(Unit.fromJson).toList());

  Future<void> create({
    required String propertyId,
    required String label,
    required int bedrooms,
    required num baseRent,
    required UnitStatus status,
  }) async {
    await _client.from(_table).insert({
      'property_id': propertyId,
      'label': label,
      'bedrooms': bedrooms,
      'base_rent': baseRent,
      'status': status.name,
    });
  }

  Future<void> update({
    required String id,
    required String label,
    required int bedrooms,
    required num baseRent,
    required UnitStatus status,
  }) async {
    await _client.from(_table).update({
      'label': label,
      'bedrooms': bedrooms,
      'base_rent': baseRent,
      'status': status.name,
    }).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

@Riverpod(keepAlive: true)
UnitRepository unitRepository(Ref ref) =>
    UnitRepository(ref.watch(supabaseClientProvider));
