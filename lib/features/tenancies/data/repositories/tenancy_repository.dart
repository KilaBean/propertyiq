import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../../shared/models/rent_cycle.dart';
import '../../../../shared/models/tenancy.dart';
import '../../../../shared/models/tenancy_status.dart';

part 'tenancy_repository.g.dart';

/// Result of inviting a tenant.
///
/// There is deliberately no password here: the tenant sets their own from the
/// emailed invite link, so nothing in this app ever holds their credential.
/// [invited] is false when the address already had an account, in which case it
/// was simply linked to the tenancy and no email was sent.
class TenantInvite {
  const TenantInvite({required this.email, required this.invited});

  final String email;
  final bool invited;
}

/// Data access for `tenancies`. Creation goes through the `create_tenancy`
/// RPC (security definer) so an already-registered tenant is linked by email;
/// updates/reads use the table under RLS.
class TenancyRepository {
  TenancyRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'tenancies';

  Stream<List<Tenancy>> watchByUnit(String unitId) => _client
      .from(_table)
      .stream(primaryKey: ['id'])
      .eq('unit_id', unitId)
      .order('created_at')
      .map((rows) => rows.map(Tenancy.fromJson).toList());

  /// Invites the tenant (sends the invite email) and creates the tenancy, all
  /// via the `invite-tenant` Edge Function. Tenants are never self-registered,
  /// so assignment always goes through the invite.
  Future<TenantInvite> create({
    required String unitId,
    required String tenantEmail,
    required String fullName,
    required String phone,
    required num rentAmount,
    required num utilityAmount,
    required num depositAmount,
    required String emergencyContact,
    required RentCycle rentCycle,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final res = await _client.functions.invoke('invite-tenant', body: {
      'unitId': unitId,
      'email': tenantEmail,
      'fullName': fullName,
      'phone': phone,
      'rentAmount': rentAmount,
      'utilityAmount': utilityAmount,
      'depositAmount': depositAmount,
      'emergencyContact': emergencyContact,
      'rentCycle': rentCycle.name,
      'startDate': _date(startDate),
      'endDate': endDate == null ? null : _date(endDate),
    });
    final data = (res.data as Map).cast<String, dynamic>();
    return TenantInvite(
      email: tenantEmail,
      invited: data['invited'] == true,
    );
  }

  Future<void> update({
    required String id,
    required num rentAmount,
    required num utilityAmount,
    required num depositAmount,
    required String emergencyContact,
    required RentCycle rentCycle,
    required DateTime startDate,
    DateTime? endDate,
    required TenancyStatus status,
  }) async {
    await _client.from(_table).update({
      'rent_amount': rentAmount,
      'utility_amount': utilityAmount,
      'deposit_amount': depositAmount,
      'emergency_contact': emergencyContact,
      'rent_cycle': rentCycle.name,
      'start_date': _date(startDate),
      'end_date': endDate == null ? null : _date(endDate),
      'status': status.name,
    }).eq('id', id);
  }

  Future<void> endTenancy(String id) async {
    await _client.from(_table).update({'status': 'ended'}).eq('id', id);
  }

  /// Emails a password-reset link to the tenant on a unit the manager owns
  /// (via the `reset-tenant-password` function). Returns the address it was
  /// sent to. No password is generated or returned — the tenant sets their own.
  Future<String?> sendTenantPasswordReset({
    required String unitId,
    required String tenantId,
  }) async {
    final res = await _client.functions.invoke('reset-tenant-password', body: {
      'unitId': unitId,
      'tenantId': tenantId,
    });
    final data = (res.data as Map).cast<String, dynamic>();
    return data['emailSent'] == true ? data['email'] as String? : null;
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Minimal date ranges for every tenancy visible to the caller (RLS scopes
  /// this to the manager's own units). Used to derive historical occupancy —
  /// a unit counts as occupied in a month if any tenancy overlaps it,
  /// regardless of the tenancy's current status.
  Future<List<Map<String, dynamic>>> fetchDateRanges() async {
    final rows =
        await _client.from(_table).select('unit_id, start_date, end_date');
    return rows;
  }

  /// The tenant's active lease with its unit + property embedded. Returns the
  /// raw row (caller maps it) or null when there is no active lease.
  Future<Map<String, dynamic>?> fetchActiveLease(String tenantId) async {
    final rows = await _client
        .from(_table)
        .select('*, units(*, properties(*))')
        .eq('tenant_id', tenantId)
        .eq('status', 'active')
        .order('start_date', ascending: false)
        .limit(1);
    return rows.isEmpty ? null : rows.first;
  }

  static String _date(DateTime d) => d.toIso8601String().split('T').first;
}

@Riverpod(keepAlive: true)
TenancyRepository tenancyRepository(Ref ref) =>
    TenancyRepository(ref.watch(supabaseClientProvider));
