import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/widgets/loading_skeleton.dart';
import 'package:propertyiq/core/widgets/async_value_view.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

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
