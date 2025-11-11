import 'package:flutter_test/flutter_test.dart';

import 'presentation/login/login_screen_test.dart' as login;
import 'presentation/login/login_with_email_password_screen_test.dart'
    as login_with_email_password;
import 'presentation/login/login_with_google_test.dart' as login_with_google;
import 'presentation/profile/profile_screen_test.dart' as profile;

void main() {
  group('Login Tests', login.main);
  group('Login With Email Tests', login_with_email_password.main);
  group('Login With Google Tests', login_with_google.main);
  group('Profile Tests', profile.main);
}
