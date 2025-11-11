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
    'open app, tap continue with Google, login successfully, '
    'verify products are displayed',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      mockFirebaseAuthService.loginWithGoogleShouldFail = false;

      await initializeApp(
        firebaseAuthService: mockFirebaseAuthService,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      await $(keys.signInPage.continueWithGoogleButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Premium Wireless Headphones'), findsOneWidget);
      expect(find.text('Smart Fitness Watch'), findsOneWidget);
      expect(find.byKey(keys.homePage.productCardKey), findsExactly(2));
    },
  );

  patrolTest(
    'login with Google should show error when login fails',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      mockFirebaseAuthService.loginWithGoogleShouldFail = true;
      mockFirebaseAuthService.loginWithGoogleError = 'Google sign-in failed';

      await initializeApp(
        firebaseAuthService: mockFirebaseAuthService,
        dio: mockDio,
      );
      await $.pumpWidgetAndSettle(const MainApp());

      await $(keys.signInPage.continueWithGoogleButton).tap();
      await $.pumpAndSettle();

      expect(find.text('Google sign-in failed'), findsOneWidget);
    },
  );
}
