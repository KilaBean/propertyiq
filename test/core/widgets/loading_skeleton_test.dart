import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/widgets/loading_skeleton.dart';
import 'package:propertyiq/core/widgets/async_value_view.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  _unboundedHeightSlotTests();

  group('ListRowSkeleton', () {
    testWidgets('shows a leading placeholder by default', (tester) async {
      await tester.pumpWidget(wrap(const ListRowSkeleton()));
      // 3 skeleton bricks: leading + title + subtitle + trailing = 4.
      expect(find.byType(LoadingSkeleton), findsNWidgets(4));
    });

    testWidgets('omits the leading and trailing bricks when asked',
        (tester) async {
      await tester.pumpWidget(wrap(
        const ListRowSkeleton(hasLeading: false, hasTrailing: false),
      ));
      // Just title + subtitle.
      expect(find.byType(LoadingSkeleton), findsNWidgets(2));
    });
  });

  testWidgets('ListSkeleton renders the requested row count', (tester) async {
    await tester.pumpWidget(wrap(const ListSkeleton(count: 3)));
    expect(find.byType(ListRowSkeleton), findsNWidgets(3));
  });

  testWidgets('MetricCardSkeleton renders without throwing', (tester) async {
    await tester.pumpWidget(wrap(
      const SizedBox(width: 200, height: 160, child: MetricCardSkeleton()),
    ));
    expect(find.byType(MetricCardSkeleton), findsOneWidget);
  });

  group('AsyncValueView loading override', () {
    testWidgets('uses the supplied skeleton instead of the default spinner',
        (tester) async {
      await tester.pumpWidget(wrap(
        AsyncValueView<int>(
          value: const AsyncLoading(),
          data: (_) => const SizedBox(),
          loading: (_) => const ListSkeleton(count: 2),
        ),
      ));

      expect(find.byType(ListSkeleton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('falls back to the spinner when no skeleton is given',
        (tester) async {
      await tester.pumpWidget(wrap(
        AsyncValueView<int>(
          value: const AsyncLoading(),
          data: (_) => const SizedBox(),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

/// AsyncValueView's cross-fade (AnimatedSwitcher) wraps its child in a Stack
/// during the transition. This pins that it doesn't blow up when the view
/// sits inside a ListView's children -- an unbounded-height slot, exactly the
/// dashboard's own layout for its stats card -- as long as the content being
/// switched between has its own definite intrinsic size, which every current
/// call site's data/loading/error widgets do.
void _unboundedHeightSlotTests() {
  testWidgets(
      'AsyncValueView survives an unbounded-height ListView slot through a '
      'loading -> data -> error -> data cycle', (tester) async {
    final controller = StreamController<int>();
    addTearDown(controller.close);

    Widget host() => MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const Text('above'),
                StreamBuilder<int>(
                  stream: controller.stream,
                  builder: (context, snapshot) {
                    final AsyncValue<int> value = snapshot.hasError
                        ? AsyncValue.error(snapshot.error!, StackTrace.empty)
                        : snapshot.hasData
                            ? AsyncValue.data(snapshot.data!)
                            : const AsyncValue.loading();
                    return AsyncValueView<int>(
                      value: value,
                      data: (v) => SizedBox(
                        height: 132,
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (var i = 0; i < v; i++) Card(child: Text('$i')),
                          ],
                        ),
                      ),
                      loading: (_) => const _MetricsSkeletonStandIn(),
                    );
                  },
                ),
                const Text('below'),
              ],
            ),
          ),
        );

    await tester.pumpWidget(host());
    expect(tester.takeException(), isNull);

    controller.add(4);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220)); // let the fade finish
    expect(tester.takeException(), isNull);
    expect(find.text('above'), findsOneWidget);
    expect(find.text('below'), findsOneWidget);

    controller.addError(Exception('boom'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(tester.takeException(), isNull);

    controller.add(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(tester.takeException(), isNull);
  });
}

/// Stands in for dashboard_screen's private _MetricsSkeleton -- same shape
/// (a shrinkWrap grid at a fixed extent), without reaching into that file's
/// private class.
class _MetricsSkeletonStandIn extends StatelessWidget {
  const _MetricsSkeletonStandIn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(4, (_) => const MetricCardSkeleton()),
      ),
    );
  }
}
