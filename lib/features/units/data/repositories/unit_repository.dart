import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../../shared/models/unit.dart';

part 'unit_repository.g.dart';

/// Data access for `units`. RLS scopes every row to units inside a property
/// the signed-in manager owns.
///
/// `status` is deliberately absent from the write methods: since migration
/// 0012 it is derived from the unit's tenancies by a database trigger, and a
/// BEFORE UPDATE trigger overwrites anything the client tries to send.
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
  }) async {
    await _client.from(_table).insert({
      'property_id': propertyId,
      'label': label,
      'bedrooms': bedrooms,
      'base_rent': baseRent,
    });
  }

  Future<void> update({
    required String id,
    required String label,
    required int bedrooms,
    required num baseRent,
  }) async {
    await _client.from(_table).update({
      'label': label,
      'bedrooms': bedrooms,
      'base_rent': baseRent,
    }).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

@Riverpod(keepAlive: true)
UnitRepository unitRepository(Ref ref) =>
    UnitRepository(ref.watch(supabaseClientProvider));
