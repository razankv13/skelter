import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class LocalAuthService {
  LocalAuthService();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } catch (e) {
      debugPrint('[LocalAuthService].isBiometricAvailable error: $e');
      return false;
    }
  }

  Future<List<BiometricType>> _getEnrolledBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[LocalAuthService]._getEnrolledBiometrics error: $e');
      return [];
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await _getEnrolledBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('[LocalAuthService].hasEnrolledBiometrics error: $e');
      return false;
    }
  }

  Future<bool> authenticateUser() async {
    try {
      final enrolledBiometrics = await _getEnrolledBiometrics();
      final reason = _buildAuthenticationReason(enrolledBiometrics);

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
      );
    } catch (e) {
      debugPrint('[LocalAuthService].authenticateUser error: $e');
      return false;
    }
  }

  String _buildAuthenticationReason(List<BiometricType> types) {
    try {
      final supportsFace = types.contains(BiometricType.face);

      if (Platform.isIOS) {
        return supportsFace ? 'Unlock with Face ID' : 'Unlock with Touch ID';
      }
      return 'Authenticate securely to continue';
    } catch (e) {
      debugPrint('[LocalAuthService]._buildAuthenticationReason error: $e');
      return 'Authentication required';
    }
  }
}
