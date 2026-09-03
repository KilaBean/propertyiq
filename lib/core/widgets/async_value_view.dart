import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders an [AsyncValue] with consistent loading / error / data states so
/// every screen handles the three states the same way (DoD requirement).
///
/// [loading] lets a screen show a skeleton shaped like its own content
/// (see core/widgets/loading_skeleton.dart) instead of the default spinner —
/// worth doing for a list, where the reader can already see where each row
/// will land; not worth a bespoke shape for most one-off detail screens, so
/// the spinner stays the default rather than something every call site has
/// to opt out of.
///
/// Cross-fades between states (150-250ms per CLAUDE.md's MOTION section)
/// rather than cutting. The fade is keyed on which branch actually ran, not
/// on `value`'s own type: `skipLoadingOnReload`/`skipLoadingOnRefresh` route
/// a reload-with-previous-data through `data` while `value` is technically
/// still an `AsyncLoading` underneath, so keying on the raw type would fade
/// every time a background refresh finishes even though the same content was
/// on screen the whole time — exactly the "flashy" motion CLAUDE.md says to
/// avoid, on the one path (pull-to-refresh, realtime updates) where it would
/// fire constantly.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback? onRetry;
  final WidgetBuilder? loading;

  @override
  Widget build(BuildContext context) {
    late final String kind;
    final child = value.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (v) {
        kind = 'data';
        return data(v);
      },
      loading: () {
        kind = 'loading';
        return loading?.call(context) ??
            const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        kind = 'error';
        return _ErrorView(message: '$error', onRetry: onRetry);
      },
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(kind), child: child),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
