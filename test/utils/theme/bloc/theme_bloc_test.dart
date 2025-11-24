import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/services/theme_service.dart';
import 'package:skelter/utils/theme/bloc/theme_bloc.dart';
import 'package:skelter/utils/theme/bloc/theme_event.dart';
import 'package:skelter/utils/theme/bloc/theme_state.dart';

class MockThemeService extends Mock implements ThemeService {}

void main() {
  late MockThemeService mockThemeService;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    mockThemeService = MockThemeService();
  });

  group('ThemeBloc Initialization', () {
    blocTest<ThemeBloc, ThemeState>(
      'should emit initial state with default system theme mode',
      build: () => ThemeBloc(service: mockThemeService),
      expect: () => [],
      verify: (bloc) {
        expect(bloc.state.themeMode, ThemeMode.system);
      },
    );
  });

  group('ThemeBloc LoadTheme Event', () {
    blocTest<ThemeBloc, ThemeState>(
      'should emit state with system theme mode when no saved preference',
      build: () {
        when(() => mockThemeService.getThemeMode())
            .thenAnswer((_) async => ThemeMode.system);
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const LoadTheme()),
      expect: () => [
        const ThemeState.test(),
      ],
      verify: (_) {
        verify(() => mockThemeService.getThemeMode()).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should emit state with light theme mode when saved preference is light',
      build: () {
        when(() => mockThemeService.getThemeMode())
            .thenAnswer((_) async => ThemeMode.light);
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const LoadTheme()),
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockThemeService.getThemeMode()).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should emit state with dark theme mode when saved preference is dark',
      build: () {
        when(() => mockThemeService.getThemeMode())
            .thenAnswer((_) async => ThemeMode.dark);
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const LoadTheme()),
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.dark),
      ],
      verify: (_) {
        verify(() => mockThemeService.getThemeMode()).called(1);
      },
    );
  });

  group('ThemeBloc SetThemeModeEvent', () {
    blocTest<ThemeBloc, ThemeState>(
      'should save and emit light theme mode',
      build: () {
        when(() => mockThemeService.saveThemeMode(ThemeMode.light))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const SetThemeModeEvent(mode: ThemeMode.light)),
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.light)).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should save and emit dark theme mode',
      build: () {
        when(() => mockThemeService.saveThemeMode(ThemeMode.dark))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const SetThemeModeEvent(mode: ThemeMode.dark)),
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.dark),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.dark)).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should save and emit system theme mode',
      build: () {
        when(() => mockThemeService.saveThemeMode(ThemeMode.system))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const SetThemeModeEvent(mode: ThemeMode.system)),
      expect: () => [
        const ThemeState.test(),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.system))
            .called(1);
      },
    );
  });

  group('ThemeBloc ToggleThemeModeEvent', () {
    blocTest<ThemeBloc, ThemeState>(
      'should toggle from system to light theme mode',
      build: () {
        when(() => mockThemeService.saveThemeMode(ThemeMode.light))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const ToggleThemeModeEvent()),
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.light)).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should toggle from light to dark theme mode',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.light));
        bloc.add(const ToggleThemeModeEvent());
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
        const ThemeState.test(themeMode: ThemeMode.dark),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.dark)).called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should toggle from dark to system theme mode',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.dark));
        bloc.add(const ToggleThemeModeEvent());
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.dark),
        const ThemeState.test(),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.system))
            .called(1);
      },
    );
  });

  group('ThemeBloc Multiple Events', () {
    blocTest<ThemeBloc, ThemeState>(
      'should handle multiple SetThemeModeEvent calls',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.light));
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.dark));
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.system));
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
        const ThemeState.test(themeMode: ThemeMode.dark),
        const ThemeState.test(),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.light)).called(1);
        verify(() => mockThemeService.saveThemeMode(ThemeMode.dark)).called(1);
        verify(() => mockThemeService.saveThemeMode(ThemeMode.system))
            .called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should handle multiple ToggleThemeModeEvent calls',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const ToggleThemeModeEvent());
        bloc.add(const ToggleThemeModeEvent());
        bloc.add(const ToggleThemeModeEvent());
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
        const ThemeState.test(themeMode: ThemeMode.dark),
        const ThemeState.test(),
      ],
      verify: (_) {
        verify(() => mockThemeService.saveThemeMode(ThemeMode.light)).called(1);
        verify(() => mockThemeService.saveThemeMode(ThemeMode.dark)).called(1);
        verify(() => mockThemeService.saveThemeMode(ThemeMode.system))
            .called(1);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should handle LoadTheme followed by SetThemeModeEvent',
      build: () {
        when(() => mockThemeService.getThemeMode())
            .thenAnswer((_) async => ThemeMode.dark);
        when(() => mockThemeService.saveThemeMode(ThemeMode.light))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const LoadTheme());
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.light));
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.dark),
        const ThemeState.test(themeMode: ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockThemeService.getThemeMode()).called(1);
        verify(() => mockThemeService.saveThemeMode(ThemeMode.light)).called(1);
      },
    );
  });

  group('ThemeBloc State Persistence', () {
    blocTest<ThemeBloc, ThemeState>(
      'should maintain theme mode after multiple events',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const SetThemeModeEvent(mode: ThemeMode.dark));
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.dark),
      ],
      verify: (bloc) {
        expect(bloc.state.themeMode, ThemeMode.dark);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'should preserve theme mode when toggling through all modes',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenAnswer((_) async => {});
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) {
        bloc.add(const ToggleThemeModeEvent()); // system -> light
        bloc.add(const ToggleThemeModeEvent()); // light -> dark
        bloc.add(const ToggleThemeModeEvent()); // dark -> system
      },
      expect: () => [
        const ThemeState.test(themeMode: ThemeMode.light),
        const ThemeState.test(themeMode: ThemeMode.dark),
        const ThemeState.test(),
      ],
      verify: (bloc) {
        expect(bloc.state.themeMode, ThemeMode.system);
      },
    );
  });

  group('ThemeBloc Error Handling', () {
    blocTest<ThemeBloc, ThemeState>(
      'should handle service errors gracefully when loading theme',
      build: () {
        when(() => mockThemeService.getThemeMode())
            .thenThrow(Exception('Failed to load theme'));
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const LoadTheme()),
      errors: () => [
        isA<Exception>(),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'should handle service errors gracefully when saving theme',
      build: () {
        when(() => mockThemeService.saveThemeMode(any()))
            .thenThrow(Exception('Failed to save theme'));
        return ThemeBloc(service: mockThemeService);
      },
      act: (bloc) => bloc.add(const SetThemeModeEvent(mode: ThemeMode.dark)),
      errors: () => [
        isA<Exception>(),
      ],
    );
  });

  group('ThemeBloc State Equality', () {
    test('ThemeState with same themeMode should be equal', () {
      const state1 = ThemeState.test(themeMode: ThemeMode.dark);
      const state2 = ThemeState.test(themeMode: ThemeMode.dark);

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('ThemeState with different themeMode should not be equal', () {
      const state1 = ThemeState.test(themeMode: ThemeMode.dark);
      const state2 = ThemeState.test(themeMode: ThemeMode.light);

      expect(state1, isNot(equals(state2)));
    });

    test('ThemeState copyWith should create new instance with updated values',
        () {
      const original = ThemeState.test();
      final copied = original.copyWith(themeMode: ThemeMode.dark);

      expect(copied.themeMode, ThemeMode.dark);
      expect(original.themeMode, ThemeMode.system);
    });
  });

  group('ThemeBloc Event Equality', () {
    test('LoadTheme events should be equal', () {
      const event1 = LoadTheme();
      const event2 = LoadTheme();

      expect(event1, equals(event2));
    });

    test('SetThemeModeEvent with same mode should be equal', () {
      const event1 = SetThemeModeEvent(mode: ThemeMode.dark);
      const event2 = SetThemeModeEvent(mode: ThemeMode.dark);

      expect(event1, equals(event2));
    });

    test('SetThemeModeEvent with different mode should not be equal', () {
      const event1 = SetThemeModeEvent(mode: ThemeMode.dark);
      const event2 = SetThemeModeEvent(mode: ThemeMode.light);

      expect(event1, isNot(equals(event2)));
    });

    test('ToggleThemeModeEvent events should be equal', () {
      const event1 = ToggleThemeModeEvent();
      const event2 = ToggleThemeModeEvent();

      expect(event1, equals(event2));
    });
  });
}
