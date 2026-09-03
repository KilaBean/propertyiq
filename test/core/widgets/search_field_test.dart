import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/widgets/search_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('debounces onChanged rather than firing per keystroke',
      (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(wrap(SearchField(
      hintText: 'Search',
      onChanged: calls.add,
      duration: const Duration(milliseconds: 100),
    )));

    await tester.enterText(find.byType(TextField), 'l');
    await tester.pump(const Duration(milliseconds: 30));
    await tester.enterText(find.byType(TextField), 'le');
    await tester.pump(const Duration(milliseconds: 30));
    await tester.enterText(find.byType(TextField), 'lea');
    // Not settled yet -- typing within the debounce window should have
    // produced nothing so far.
    expect(calls, isEmpty);

    await tester.pump(const Duration(milliseconds: 150));
    expect(calls, ['lea']);
  });

  testWidgets('the clear button empties the field and fires immediately',
      (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(wrap(SearchField(
      hintText: 'Search',
      onChanged: calls.add,
      duration: const Duration(milliseconds: 300),
    )));

    await tester.enterText(find.byType(TextField), 'leak');
    await tester.pump(const Duration(milliseconds: 350));
    expect(calls, ['leak']);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(find.text('leak'), findsNothing);
    expect(calls.last, '');
  });

  testWidgets('shows no clear button when empty', (tester) async {
    await tester.pumpWidget(wrap(SearchField(
      hintText: 'Search',
      onChanged: (_) {},
    )));

    expect(find.byTooltip('Clear search'), findsNothing);
  });
}
