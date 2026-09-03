import 'package:flutter/material.dart';

/// The base "brick" for a loading skeleton: a soft-edged rectangle that
/// gently pulses in place of content that hasn't arrived yet.
///
/// A skeleton that echoes the eventual layout reads as *faster* than a bare
/// spinner at identical latency — the reader can already see where the title,
/// the thumbnail, the price will land. Compose this into per-screen shapes
/// (see [ListRowSkeleton], [MetricCardSkeleton] below) rather than using it
/// bare; a lone pulsing box carries none of that benefit.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  // A slow, continuous pulse rather than a one-shot transition, so its pace
  // is intentionally outside CLAUDE.md's 150-250ms motion window for
  // transitions — this loops for as long as the content is loading.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.5 + (_controller.value * 0.35)),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Mirrors the shape shared by PropertyCard, UnitCard and the maintenance
/// list rows: an optional leading thumbnail, a title line, a subtitle line,
/// and an optional trailing mark.
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  final bool hasLeading;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (hasLeading) ...[
              const LoadingSkeleton(width: 44, height: 44, borderRadius: 10),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingSkeleton(width: 160, height: 15),
                  const SizedBox(height: 8),
                  LoadingSkeleton(width: hasLeading ? 100 : 130, height: 12),
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: 12),
              const LoadingSkeleton(width: 26, height: 26, borderRadius: 13),
            ],
          ],
        ),
      ),
    );
  }
}

/// A vertical run of [ListRowSkeleton] — a list screen's loading state.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.count = 6,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  final int count;
  final bool hasLeading;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: count,
      itemBuilder: (_, _) =>
          ListRowSkeleton(hasLeading: hasLeading, hasTrailing: hasTrailing),
    );
  }
}

/// Mirrors MetricCard's icon-chip + big value + label stack.
class MetricCardSkeleton extends StatelessWidget {
  const MetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            LoadingSkeleton(width: 40, height: 40, borderRadius: 12),
            SizedBox(height: 12),
            LoadingSkeleton(width: 48, height: 22),
            SizedBox(height: 6),
            LoadingSkeleton(width: 64, height: 12),
          ],
        ),
      ),
    );
  }
}
