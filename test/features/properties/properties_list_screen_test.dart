import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/layout/breakpoints.dart';
import 'package:propertyiq/core/theme/app_theme.dart';
import 'package:propertyiq/core/widgets/loading_skeleton.dart';
import 'package:propertyiq/core/widgets/property_card.dart';
import 'package:propertyiq/features/properties/presentation/providers/property_providers.dart';
import 'package:propertyiq/features/properties/presentation/screens/properties_list_screen.dart';
import 'package:propertyiq/shared/models/property.dart';

/// The Definition of Done requires loading, empty, error and data states on
/// every screen. This pins all four for the properties list, plus the
/// responsive switch from a column to a grid.
Property _property(String id, String name) =>
    Property(id: id, managerId: 'm1', name: name, currency: 'NGN');

/// The screen sizes itself from the surface, so the responsive tests set
/// `tester.view.physicalSize` rather than passing a size in here.
Widget _app(Stream<List<Property>> stream) => ProviderScope(
      overrides: [propertiesListProvider.overrideWith((ref) => stream)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const PropertiesListScreen(),
      ),
    );

void main() {
  testWidgets('shows a loading skeleton while the stream has not emitted',
      (tester) async {
    await tester.pumpWidget(_app(const Stream<List<Property>>.empty()));
    await tester.pump();

    expect(find.byType(ListSkeleton), findsOneWidget);
  });

  testWidgets('shows the empty state with a call to action', (tester) async {
    await tester.pumpWidget(_app(Stream.value(const <Property>[])));
    await tester.pumpAndSettle();

    expect(find.text('No properties yet'), findsOneWidget);
    expect(find.text('Add property'), findsOneWidget);
    expect(find.byType(PropertyCard), findsNothing);
  });

  testWidgets('shows a retry affordance when the stream errors',
      (tester) async {
    await tester.pumpWidget(
      _app(Stream.error(Exception('network unreachable'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });

  testWidgets('renders one card per property', (tester) async {
    await tester.pumpWidget(_app(Stream.value([
      _property('p1', 'Lekki Court'),
      _property('p2', 'Yaba Heights'),
    ])));
    await tester.pumpAndSettle();

    expect(find.byType(PropertyCard), findsNWidgets(2));
    expect(find.text('Lekki Court'), findsOneWidget);
    expect(find.text('Yaba Heights'), findsOneWidget);
  });

  group('responsive layout', () {
    testWidgets('uses a single column on a phone', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(Stream.value([
        _property('p1', 'Lekki Court'),
        _property('p2', 'Yaba Heights'),
      ])));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('switches to a grid on a tablet', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(Stream.value([
        _property('p1', 'Lekki Court'),
        _property('p2', 'Yaba Heights'),
      ])));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(PropertyCard), findsNWidgets(2));
    });
  });

  group('FormFactor', () {
    test('maps widths to the documented breakpoints', () {
      expect(FormFactor.of(390), FormFactor.compact);
      expect(FormFactor.of(599), FormFactor.compact);
      expect(FormFactor.of(600), FormFactor.medium);
      expect(FormFactor.of(999), FormFactor.medium);
      expect(FormFactor.of(1000), FormFactor.expanded);
    });

    test('column counts grow with available width', () {
      expect(FormFactor.compact.cardColumns, 1);
      expect(FormFactor.medium.cardColumns, 2);
      expect(FormFactor.expanded.cardColumns, 3);
    });
  });
}
