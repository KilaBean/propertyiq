import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/theme/app_theme.dart';
import 'package:propertyiq/core/widgets/metric_card.dart';
import 'package:propertyiq/core/widgets/round_icon_button.dart';
import 'package:propertyiq/core/widgets/status_badge.dart';
import 'package:propertyiq/core/widgets/unit_card.dart';
import 'package:propertyiq/shared/models/unit.dart';
import 'package:propertyiq/shared/models/unit_status.dart';

// Guards the accessibility contract in the design system: every control has an
// accessible name, and touch targets meet 44px. Easy to regress by adding one
// more icon-only button.

/// Wraps in the app's real theme — StatusBadge and friends read design-system
/// tokens from a ThemeExtension, so a bare MaterialApp is not representative.
Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('RoundIconButton', () {
    testWidgets('exposes its label to the semantics tree', (tester) async {
      await tester.pumpWidget(_wrap(
        RoundIconButton(
          icon: Icons.notifications_none,
          label: 'Notifications',
          onTap: () {},
        ),
      ));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Notifications')),
        isNotNull,
      );
    });

    testWidgets('meets the 44px minimum touch target', (tester) async {
      await tester.pumpWidget(_wrap(
        RoundIconButton(icon: Icons.add, label: 'Add', onTap: () {}),
      ));

      final size = tester.getSize(find.byType(RoundIconButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('is operable', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(
        RoundIconButton(icon: Icons.add, label: 'Add', onTap: () => taps++),
      ));

      await tester.tap(find.byType(RoundIconButton));
      expect(taps, 1);
    });
  });

  group('MetricCard', () {
    testWidgets('reads as one node pairing label and value', (tester) async {
      // Previously the two Texts were separate nodes, so a screen reader
      // announced "21" and "Occupied" with no relationship between them.
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 200,
          height: 160,
          child: MetricCard(
            label: 'Occupied',
            value: '21',
            icon: Icons.person_outline,
          ),
        ),
      ));

      expect(find.bySemanticsLabel('Occupied: 21'), findsOneWidget);
    });
  });

  group('UnitCard', () {
    testWidgets('summarises the whole row in one label', (tester) async {
      await tester.pumpWidget(_wrap(
        UnitCard(
          unit: const Unit(
            id: 'u1',
            propertyId: 'p1',
            label: 'Flat 2B',
            bedrooms: 2,
            baseRent: 450000,
            status: UnitStatus.occupied,
          ),
          currency: 'NGN',
          onTap: () {},
        ),
      ));

      // One node carrying the whole row, rather than four disconnected Texts.
      expect(find.bySemanticsLabel(RegExp('Flat 2B')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('2 bedroom')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Occupied')), findsOneWidget);
    });
  });

  group('StatusBadge', () {
    testWidgets('announces its label and hides the decorative dot',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Overdue', tone: StatusTone.danger),
      ));

      expect(find.text('Overdue'), findsOneWidget);
      // The dot carries no information the label doesn't already give.
      final semantics = tester.getSemantics(find.text('Overdue'));
      expect(semantics.label, 'Overdue');
    });
  });
}
