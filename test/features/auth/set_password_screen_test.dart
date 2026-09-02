import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/auth/data/repositories/auth_repository.dart';
import 'package:propertyiq/features/auth/presentation/screens/set_password_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.changePassword(any())).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: SetPasswordScreen()),
        ),
      );

  testWidgets('renders both password fields', (tester) async {
    await pump(tester);

    expect(find.text('Choose a password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('rejects a password under 8 characters', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'short');
    await tester.enterText(find.byType(TextFormField).last, 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Set password'));
    await tester.pump();

    expect(find.text('At least 8 characters'), findsOneWidget);
    verifyNever(() => repo.changePassword(any()));
  });

  testWidgets('rejects a mismatched confirmation', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'correct-horse');
    await tester.enterText(find.byType(TextFormField).last, 'battery-staple');
    await tester.tap(find.widgetWithText(FilledButton, 'Set password'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
    verifyNever(() => repo.changePassword(any()));
  });

  testWidgets('submits a valid matching password', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'correct-horse');
    await tester.enterText(find.byType(TextFormField).last, 'correct-horse');
    await tester.tap(find.widgetWithText(FilledButton, 'Set password'));
    await tester.pumpAndSettle();

    verify(() => repo.changePassword('correct-horse')).called(1);
  });

  testWidgets('the visibility toggle is reachable by its tooltip',
      (tester) async {
    await pump(tester);

    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
