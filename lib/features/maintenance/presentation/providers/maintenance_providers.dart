import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/maintenance_status.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/maintenance_repository.dart';

part 'maintenance_providers.g.dart';

/// Requests fetched per page. `fetchForManager`/`fetchForTenant` are
/// otherwise unbounded and only grow over a portfolio's lifetime.
const _pageSize = 20;

/// One list screen's accumulated state: the pages loaded so far, whether
/// another page might exist, and whether one is currently being fetched.
///
/// [hasMore] is a heuristic, not a count: it's true whenever the most
/// recently loaded page came back full-size, since a short page is the only
/// cheap signal this schema gives that the end has been reached.
class MaintenancePage {
  const MaintenancePage({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<MaintenanceView> items;
  final bool hasMore;
  final bool isLoadingMore;

  MaintenancePage copyWith({
    List<MaintenanceView>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MaintenancePage(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// All requests across the manager's units, paginated.
@riverpod
class ManagerRequests extends _$ManagerRequests {
  @override
  Future<MaintenancePage> build() async {
    final page = await ref
        .watch(maintenanceRepositoryProvider)
        .fetchForManager(offset: 0, limit: _pageSize);
    return MaintenancePage(
      items: page,
      hasMore: page.length == _pageSize,
      isLoadingMore: false,
    );
  }

  /// Fetches the next page and appends it. A no-op while a fetch is already
  /// in flight or the previous page came back short (nothing left to load).
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await ref
          .read(maintenanceRepositoryProvider)
          .fetchForManager(offset: current.items.length, limit: _pageSize);
      final refreshed = state.value ?? current;
      state = AsyncData(
        MaintenancePage(
          items: [...refreshed.items, ...next],
          hasMore: next.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Keep the items already on screen; just release the loading flag so
      // scrolling back down tries again, rather than turning a failed "next
      // page" fetch into a full-screen error over data the user already has.
      final refreshed = state.value ?? current;
      state = AsyncData(refreshed.copyWith(isLoadingMore: false));
    }
  }

  /// Applies a status change already written to the database (see
  /// `MaintenanceController.setStatus`) to the row already held in memory,
  /// instead of invalidating and re-fetching every page loaded so far for a
  /// change to one row whose new value is already known.
  void patchStatus(String requestId, MaintenanceStatus status) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final v in current.items)
            if (v.request.id == requestId)
              MaintenanceView(
                request: v.request.copyWith(status: status),
                unitLabel: v.unitLabel,
                propertyName: v.propertyName,
                propertyAddress: v.propertyAddress,
                tenantName: v.tenantName,
              )
            else
              v,
        ],
      ),
    );
  }
}

/// The signed-in tenant's own requests, paginated.
@riverpod
class TenantRequests extends _$TenantRequests {
  @override
  Future<MaintenancePage> build() async {
    final uid = ref.watch(sessionProvider)?.user.id;
    if (uid == null) {
      return const MaintenancePage(items: [], hasMore: false, isLoadingMore: false);
    }
    final page = await ref
        .watch(maintenanceRepositoryProvider)
        .fetchForTenant(uid, offset: 0, limit: _pageSize);
    return MaintenancePage(
      items: page,
      hasMore: page.length == _pageSize,
      isLoadingMore: false,
    );
  }

  /// See [ManagerRequests.loadMore].
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    final uid = ref.read(sessionProvider)?.user.id;
    if (uid == null) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await ref
          .read(maintenanceRepositoryProvider)
          .fetchForTenant(uid, offset: current.items.length, limit: _pageSize);
      final refreshed = state.value ?? current;
      state = AsyncData(
        MaintenancePage(
          items: [...refreshed.items, ...next],
          hasMore: next.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      final refreshed = state.value ?? current;
      state = AsyncData(refreshed.copyWith(isLoadingMore: false));
    }
  }
}

/// A single request (RLS scopes visibility to its tenant or managing manager).
@riverpod
Future<MaintenanceView> maintenanceDetail(Ref ref, String id) =>
    ref.watch(maintenanceRepositoryProvider).fetchDetail(id);

/// A short-lived signed URL for a stored maintenance photo (cached per path).
@riverpod
Future<String> maintenancePhotoUrl(Ref ref, String path) =>
    ref.watch(maintenanceRepositoryProvider).signedPhotoUrl(path);
