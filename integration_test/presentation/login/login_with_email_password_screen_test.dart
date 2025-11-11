import 'package:dio/dio.dart';
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
    'open app, navigate to email login, login with email and password, '
    'verify products are displayed',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      mockFirebaseAuthService.signInWithEmailShouldFail = false;
      mockFirebaseAuthService.signInWithEmailUserEmail = 'test@example.com';
      mockFirebaseAuthService.signInWithEmailUserVerified = true;

      await initializeApp(
        firebaseAuthService: mockFirebaseAuthService,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      await $(keys.signInPage.continueWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Login with email'), findsOneWidget);

      await $(keys.signInPage.emailTextField).enterText('test@example.com');
      await $(keys.signInPage.passwordTextField).enterText('password123');
      await $.pumpAndSettle();

      await $(keys.signInPage.loginWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Premium Wireless Headphones'), findsOneWidget);
      expect(find.text('Smart Fitness Watch'), findsOneWidget);
      expect(find.byKey(keys.homePage.productCardKey), findsExactly(2));
    },
  );

  patrolTest(
    'login with email should fail when email is not verified',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      mockFirebaseAuthService.signInWithEmailShouldFail = false;
      mockFirebaseAuthService.signInWithEmailUserEmail =
          'unverified@example.com';
      mockFirebaseAuthService.signInWithEmailUserVerified = false;

      await initializeApp(
        firebaseAuthService: mockFirebaseAuthService,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      await $(keys.signInPage.continueWithEmailButton).tap();
      await $.pumpAndSettle();

      await $(keys.signInPage.emailTextField)
          .enterText('unverified@example.com');
      await $(keys.signInPage.passwordTextField).enterText('password123');
      await $.pumpAndSettle();

      await $(keys.signInPage.loginWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);
    },
  );

  patrolTest(
    'login with email should show error when credentials are invalid',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      mockFirebaseAuthService.signInWithEmailShouldFail = true;
      mockFirebaseAuthService.signInWithEmailError =
          'Invalid email or password';

      await initializeApp(
        firebaseAuthService: mockFirebaseAuthService,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      await $(keys.signInPage.continueWithEmailButton).tap();
      await $.pumpAndSettle();

      await $(keys.signInPage.emailTextField).enterText('invalid@example.com');
      await $(keys.signInPage.passwordTextField).enterText('wrongpassword');
      await $.pumpAndSettle();

      await $(keys.signInPage.loginWithEmailButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
    },
  );
}
