import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol/patrol.dart';
import 'package:skelter/constants/integration_test_keys.dart';
import 'package:skelter/initialize_app.dart';
import 'package:skelter/main.dart';

import '../../demo_product_response.dart';
import '../../mock_firebase_auth.dart';

class MockDio extends Mock implements Dio {}

class MockDioResponse<T> extends Mock implements Response<T> {}

void main() {
  final mockDio = MockDio();
  final mockFirebaseAuthService = MockFirebaseAuthService();
  final mockFirebaseAuth = MockFirebaseAuth();

  setUpAll(() {
    final mockResponse = MockDioResponse<List<dynamic>>();

    when(() => mockResponse.statusCode).thenReturn(200);
    when(() => mockResponse.data).thenReturn(productsResponse);
    when(
      () => mockDio.get(
        any(),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => mockResponse);
    when(() => mockDio.interceptors).thenReturn(Interceptors());
  });

  patrolTest(
    'sign up with email test',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      await initializeApp(
        firebaseAuth: mockFirebaseAuth,
        firebaseAuthService: mockFirebaseAuthService,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      // SCENARIO 1: Successful signup with email verification
      mockFirebaseAuthService.signupWithEmailShouldFail = false;
      mockFirebaseAuthService.sendVerificationShouldFail = false;
      mockFirebaseAuthService.signupWithEmailUserEmail = 'newuser@example.com';
      mockFirebaseAuthService.signupWithEmailUserVerified = false;

      await $('Sign up').tap();
      await $.pumpAndSettle();

      await $(keys.signupPage.signupWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Sign up with Email'), findsOneWidget);

      await $(keys.signupPage.signupEmailTextField)
          .enterText('newuser@example.com');
      await Future.delayed(const Duration(milliseconds: 500));
      await $.pumpAndSettle();
      await $(keys.signupPage.signupEmailNextButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Create your password'), findsOneWidget);

      await $(keys.signupPage.signupPasswordTextField)
          .enterText('StrongPass123!');
      await $.pumpAndSettle();

      await $(keys.signupPage.signupConfirmPasswordTextField)
          .enterText('StrongPass123!');

      await Future.delayed(const Duration(milliseconds: 600));
      await $.pumpAndSettle();

      await $(keys.signupPage.signupPasswordNextButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);

      mockFirebaseAuth.testUser.setEmailVerified(isEmailVerified: true);
      await $.pump(const Duration(seconds: 6));
      await $.pumpAndSettle();

      expect(find.text('Premium Wireless Headphones'), findsOneWidget);
      expect(find.text('Smart Fitness Watch'), findsOneWidget);
      expect(find.byKey(keys.homePage.productCardKey), findsExactly(2));

      await $(TablerIcons.user).tap();
      await $.pumpAndSettle();
      await $('Sign out').scrollTo().tap();
      await $.pumpAndSettle();

      // SCENARIO 2: Email already in use error
      mockFirebaseAuthService.signupWithEmailShouldFail = true;
      mockFirebaseAuthService.signupWithEmailError = 'Email already in use';

      await $('Sign up').tap();
      await $.pumpAndSettle();

      await $(keys.signupPage.signupWithEmailButton).tap();
      await $.pumpAndSettle();

      await $(keys.signupPage.signupEmailTextField)
          .enterText('existing@example.com');
      await $.pumpAndSettle(timeout: const Duration(seconds: 2));

      await $(keys.signupPage.signupEmailNextButton).tap();
      await $.pumpAndSettle();

      await $(keys.signupPage.signupPasswordTextField)
          .enterText('StrongPass123!');
      await $.pumpAndSettle();

      await $(keys.signupPage.signupConfirmPasswordTextField)
          .enterText('StrongPass123!');
      await Future.delayed(const Duration(milliseconds: 600));
      await $.pumpAndSettle();

      await $(keys.signupPage.signupPasswordNextButton).tap();

      await Future.delayed(const Duration(seconds: 1));
      await $.pumpAndSettle();

      expect(find.text('Email already in use'), findsOneWidget);

      final NavigatorState navigator = $.tester.state(find.byType(Navigator));
      navigator.pop();
      await $.pump();

      // SCENARIO 3: Invalid email validation
      await $(keys.signupPage.signupEmailTextField).enterText('invalidemail');
      await Future.delayed(const Duration(milliseconds: 500));
      await $.pumpAndSettle();

      await $(keys.signupPage.signupEmailNextButton).tap();
      await $.pumpAndSettle();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    },
  );
}
