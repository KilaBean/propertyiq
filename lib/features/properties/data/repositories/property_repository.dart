import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../../shared/models/property.dart';

part 'property_repository.g.dart';

/// Data access for `properties`. All reads are RLS-scoped to the signed-in
/// manager, so no manual ownership filter is needed beyond the realtime stream.
class PropertyRepository {
  PropertyRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'properties';
  static const _bucket = 'property-photos';

  Stream<List<Property>> watchByManager(String managerId) => _client
      .from(_table)
      .stream(primaryKey: ['id'])
      .eq('manager_id', managerId)
      .order('created_at')
      .map((rows) => rows.map(Property.fromJson).toList());

  Future<Property> fetch(String id) async {
    final data = await _client.from(_table).select().eq('id', id).single();
    return Property.fromJson(data);
  }

  /// Creates the property and returns its new id (so a cover photo can be
  /// uploaded into its folder right after).
  Future<String> create({
    required String managerId,
    required String name,
    String? address,
    required String currency,
  }) async {
    final row = await _client.from(_table).insert({
      'manager_id': managerId,
      'name': name,
      'address': address,
      'currency': currency,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> update({
    required String id,
    required String name,
    String? address,
    required String currency,
  }) async {
    await _client.from(_table).update({
      'name': name,
      'address': address,
      'currency': currency,
    }).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Uploads a cover photo into the property's folder and records its path.
  /// The manager owns the row directly, so this is a plain client-side update
  /// (no RPC needed, unlike the tenant-authored maintenance photos). Returns
  /// the stored path so the caller can invalidate its signed-URL cache (the
  /// path is stable across re-uploads, so a stale cached URL would otherwise
  /// keep showing the old image).
  Future<String> uploadPhoto(String propertyId, XFile file) async {
    final bytes = await file.readAsBytes();
    final ext =
        file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
    final path = '$propertyId/cover.$ext';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/jpeg',
            upsert: true,
          ),
        );
    await _client.from(_table).update({'photo_path': path}).eq('id', propertyId);
    return path;
  }

  /// A short-lived signed URL for a stored cover photo (bucket is private).
  Future<String> signedPhotoUrl(String path) =>
      _client.storage.from(_bucket).createSignedUrl(path, 3600);
}

@Riverpod(keepAlive: true)
PropertyRepository propertyRepository(Ref ref) =>
    PropertyRepository(ref.watch(supabaseClientProvider));
