import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../../shared/models/maintenance_category.dart';
import '../../../../shared/models/maintenance_priority.dart';
import '../../../../shared/models/maintenance_request.dart';
import '../../../../shared/models/maintenance_status.dart';

part 'maintenance_repository.g.dart';

/// Result of the `maintenance-triage` Edge Function (Gemini 2.5 Flash).
/// [aiGenerated] is false when the function returned its safe fallback.
class MaintenanceTriage {
  const MaintenanceTriage({
    required this.category,
    required this.priority,
    required this.recommendation,
    required this.aiGenerated,
  });

  final MaintenanceCategory category;
  final MaintenancePriority priority;
  final String recommendation;
  final bool aiGenerated;

  factory MaintenanceTriage.fromJson(Map<String, dynamic> j) =>
      MaintenanceTriage(
        category: MaintenanceCategory.fromName(j['category'] as String?),
        priority: MaintenancePriority.fromName(j['priority'] as String?),
        recommendation: (j['recommendation'] ?? '').toString(),
        aiGenerated: j['ai_generated'] == true,
      );
}

/// A request joined with its unit label + property name, for list/detail views.
class MaintenanceView {
  const MaintenanceView({
    required this.request,
    required this.unitLabel,
    required this.propertyName,
    required this.propertyAddress,
    required this.tenantName,
  });

  final MaintenanceRequest request;
  final String unitLabel;
  final String propertyName;
  final String propertyAddress;
  final String tenantName;
}

class MaintenanceRepository {
  MaintenanceRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'maintenance_requests';
  static const _select =
      '*, units(label, properties(name, address)), '
      'tenant:profiles!maintenance_requests_tenant_id_fkey(full_name)';

  /// Calls the Gemini-backed Edge Function. The key never touches the client.
  Future<MaintenanceTriage> triage({
    required String title,
    required String description,
  }) async {
    final res = await _client.functions.invoke(
      'maintenance-triage',
      body: {'title': title, 'description': description},
    );
    final data = (res.data as Map).cast<String, dynamic>();
    return MaintenanceTriage.fromJson(data);
  }

  /// Inserts the request and returns its new id (so photos can be uploaded
  /// into its folder).
  Future<String> create({
    required String unitId,
    required String tenantId,
    required String title,
    String? description,
    required MaintenanceCategory category,
    required MaintenancePriority priority,
    String? aiRecommendation,
    required bool aiGenerated,
  }) async {
    final row = await _client.from(_table).insert({
      'unit_id': unitId,
      'tenant_id': tenantId,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'ai_recommendation': aiRecommendation,
      'ai_generated': aiGenerated,
    }).select('id').single();
    return row['id'] as String;
  }

  static const _bucket = 'maintenance-photos';

  /// Uploads photos into the request's folder; returns the stored paths.
  Future<List<String>> uploadPhotos(String requestId, List<XFile> files) async {
    final store = _client.storage.from(_bucket);
    final paths = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final bytes = await file.readAsBytes();
      final ext =
          file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
      final path = '$requestId/$i.$ext';
      await store.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: file.mimeType ?? 'image/jpeg',
          upsert: true,
        ),
      );
      paths.add(path);
    }
    return paths;
  }

  Future<void> setPhotoPaths(String id, List<String> paths) async {
    // Via a definer RPC: a tenant has no UPDATE policy on maintenance_requests,
    // so a direct update would be silently denied by RLS.
    await _client.rpc(
      'set_maintenance_photos',
      params: {'p_id': id, 'p_paths': paths},
    );
  }

  /// A short-lived signed URL for a stored photo (bucket is private).
  Future<String> signedPhotoUrl(String path) =>
      _client.storage.from(_bucket).createSignedUrl(path, 3600);

  Future<void> updateStatus(String id, MaintenanceStatus status) async {
    await _client.from(_table).update({'status': status.value}).eq('id', id);
  }

  /// Fetches one page, newest first. [offset]/[limit] back the list
  /// screens' infinite scroll (maintenance_providers.dart) -- unpaginated,
  /// this query grows without bound over a portfolio's lifetime. [query],
  /// given, matches against the title server-side -- searching only the
  /// page(s) already loaded into memory would silently hide older matches
  /// the user hasn't scrolled to yet.
  Future<List<MaintenanceView>> fetchForTenant(
    String tenantId, {
    required int offset,
    required int limit,
    String? query,
  }) async {
    var builder = _client
        .from(_table)
        .select(_select)
        .eq('tenant_id', tenantId);
    if (query != null && query.isNotEmpty) {
      builder = builder.ilike('title', '%$query%');
    }
    final rows = await builder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map(_toView).toList();
  }

  /// See [fetchForTenant] -- same pagination and search, scoped to the
  /// manager instead.
  Future<List<MaintenanceView>> fetchForManager({
    required int offset,
    required int limit,
    String? query,
  }) async {
    var builder = _client.from(_table).select(_select);
    if (query != null && query.isNotEmpty) {
      builder = builder.ilike('title', '%$query%');
    }
    final rows = await builder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map(_toView).toList();
  }

  Future<MaintenanceView> fetchDetail(String id) async {
    final row = await _client.from(_table).select(_select).eq('id', id).single();
    return _toView(row);
  }

  MaintenanceView _toView(Map<String, dynamic> row) {
    final unit = (row['units'] as Map?)?.cast<String, dynamic>();
    final property = (unit?['properties'] as Map?)?.cast<String, dynamic>();
    final tenant = (row['tenant'] as Map?)?.cast<String, dynamic>();
    return MaintenanceView(
      request: MaintenanceRequest.fromJson(row),
      unitLabel: (unit?['label'] as String?) ?? '',
      propertyName: (property?['name'] as String?) ?? '',
      propertyAddress: (property?['address'] as String?) ?? '',
      tenantName: (tenant?['full_name'] as String?) ?? '',
    );
  }
}

@Riverpod(keepAlive: true)
MaintenanceRepository maintenanceRepository(Ref ref) =>
    MaintenanceRepository(ref.watch(supabaseClientProvider));
