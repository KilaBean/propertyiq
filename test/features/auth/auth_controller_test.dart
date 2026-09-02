import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/auth/data/repositories/auth_repository.dart';
import 'package:propertyiq/features/auth/presentation/providers/auth_controller.dart';
import 'package:propertyiq/shared/models/user_role.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(UserRole.tenant);
  });

  setUp(() {
    repo = MockAuthRepository();
  });

  ProviderContainer build() {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final sub = container.listen(authControllerProvider, (_, _) {});
    addTearDown(sub.close);
    return container;
  }

  group('AuthController.signIn', () {
    test('forwards credentials and settles into data on success', () async {
      when(() => repo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      final container = build();

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'ada@example.com', password: 'hunter2!');

      verify(() => repo.signInWithPassword(
            email: 'ada@example.com',
            password: 'hunter2!',
          )).called(1);
      final state = container.read(authControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('captures a bad credential as an error state', () async {
      when(() => repo.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid login credentials'));

      final container = build();

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'ada@example.com', password: 'wrong');

      expect(container.read(authControllerProvider).hasError, isTrue);
    });
  });

  group('AuthController.signUp', () {
    test('passes the chosen role through to the repository', () async {
      // The role travels as auth metadata and is read by the handle_new_user
      // trigger, so getting it wrong silently creates the wrong kind of account.
      when(() => repo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
            role: any(named: 'role'),
          )).thenAnswer((_) async {});

      final container = build();

      await container.read(authControllerProvider.notifier).signUp(
            email: 'ada@example.com',
            password: 'hunter2!',
            fullName: 'Ada Obi',
            role: UserRole.manager,
          );

      verify(() => repo.signUp(
            email: 'ada@example.com',
            password: 'hunter2!',
            fullName: 'Ada Obi',
            role: UserRole.manager,
          )).called(1);
    });
  });

  group('AuthController.changePassword', () {
    test('returns true on success', () async {
      when(() => repo.changePassword(any())).thenAnswer((_) async {});
      final container = build();

      expect(
        await container
            .read(authControllerProvider.notifier)
            .changePassword('a-new-password'),
        isTrue,
      );
      verify(() => repo.changePassword('a-new-password')).called(1);
    });

    test('returns false when the update is rejected', () async {
      when(() => repo.changePassword(any()))
          .thenThrow(Exception('password too short'));
      final container = build();

      expect(
        await container
            .read(authControllerProvider.notifier)
            .changePassword('abc'),
        isFalse,
      );
    });
  });

  group('AuthController.signOut', () {
    test('delegates to the repository', () async {
      when(() => repo.signOut()).thenAnswer((_) async {});
      final container = build();

      await container.read(authControllerProvider.notifier).signOut();

      verify(() => repo.signOut()).called(1);
    });
  });
}
