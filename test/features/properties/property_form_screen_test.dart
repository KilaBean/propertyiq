import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/core/theme/app_theme.dart';
import 'package:propertyiq/features/auth/presentation/providers/auth_providers.dart';
import 'package:propertyiq/features/properties/data/repositories/property_repository.dart';
import 'package:propertyiq/features/properties/presentation/screens/property_form_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

final _user = User(
  id: 'manager-1',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: DateTime(2026).toIso8601String(),
);
final _session = Session(accessToken: 'token', tokenType: 'bearer', user: _user);

void main() {
  late MockPropertyRepository repo;

  setUp(() {
    repo = MockPropertyRepository();
  });

  // The form calls context.pop() on a successful submit, which needs a real
  // GoRouter with actual navigation history (not just a route table) to pop
  // back into -- so every test reaches the form by pushing onto a base route
  // rather than starting there directly.
  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: SizedBox())),
        GoRoute(path: '/form', builder: (_, _) => const PropertyFormScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          propertyRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith((ref) => _session),
        ],
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    );
    router.push('/form');
    await tester.pumpAndSettle();
  }

  testWidgets('defaults a new property to Cedi (GHS)', (tester) async {
    await pump(tester);

    final dropdown =
        tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.initialValue, 'GHS');
    expect(find.text('GHS'), findsOneWidget);
  });

  testWidgets('requires a name before it will submit', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create property'));
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    verifyNever(() => repo.create(
          managerId: any(named: 'managerId'),
          name: any(named: 'name'),
          address: any(named: 'address'),
          currency: any(named: 'currency'),
        ));
  });

  testWidgets('submits with just a name -- address is genuinely optional',
      (tester) async {
    when(() => repo.create(
          managerId: any(named: 'managerId'),
          name: any(named: 'name'),
          address: any(named: 'address'),
          currency: any(named: 'currency'),
        )).thenAnswer((_) async => 'property-1');

    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Lekki Court');
    await tester.tap(find.widgetWithText(FilledButton, 'Create property'));
    await tester.pumpAndSettle();

    verify(() => repo.create(
          managerId: 'manager-1',
          name: 'Lekki Court',
          address: null,
          currency: 'GHS',
        )).called(1);
  });

  testWidgets('sends the currency actually selected in the dropdown',
      (tester) async {
    when(() => repo.create(
          managerId: any(named: 'managerId'),
          name: any(named: 'name'),
          address: any(named: 'address'),
          currency: any(named: 'currency'),
        )).thenAnswer((_) async => 'property-1');

    await pump(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Accra Heights');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NGN').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create property'));
    await tester.pumpAndSettle();

    verify(() => repo.create(
          managerId: 'manager-1',
          name: 'Accra Heights',
          address: null,
          currency: 'NGN',
        )).called(1);
  });
}
