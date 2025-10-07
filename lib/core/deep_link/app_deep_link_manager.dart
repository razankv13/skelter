import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:skelter/main.dart';
import 'package:skelter/presentation/login/models/login_details.dart';
import 'package:skelter/routes.gr.dart';
import 'package:skelter/shared_pref/pref_keys.dart';
import 'package:skelter/shared_pref/prefs.dart';
import 'package:skelter/utils/extensions/string.dart';

class AppDeepLinkManager {
  AppDeepLinkManager._internal();
  static final AppDeepLinkManager _instance = AppDeepLinkManager._internal();
  static AppDeepLinkManager get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _linkStreamSubscription;
  Uri? _pendingDeepLink;
  bool _isProcessing = false;

  bool get hasPendingDeepLink => _pendingDeepLink != null;

  /// Initialize listener and store initial deep link
  Future<void> initialize() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _pendingDeepLink = initialUri;

      _linkStreamSubscription = _appLinks.uriLinkStream.listen(
        _handleRuntimeDeepLink,
        onError: (err) => debugPrint('[AppDeepLinkManager] Error: $err'),
        onDone: () => _linkStreamSubscription?.cancel(),
      );
    } on PlatformException catch (e) {
      debugPrint('[AppDeepLinkManager] PlatformException: $e');
    }
  }

  /// Runtime deep link handler
  Future<void> _handleRuntimeDeepLink(Uri? uri) async {
    if (uri == null) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      // Context not ready → store deep link
      _pendingDeepLink = uri;
      debugPrint('[DeepLink] Context not ready, storing deep link');
      return;
    }

    final isLoggedIn = await _checkIfUserLoggedIn();
    if (!isLoggedIn) {
      // Store deep link for post-login
      _pendingDeepLink = uri;
      debugPrint('[DeepLink] User not logged in, storing deep link');
      return;
    }

    // User logged in → process deep link immediately
    await _processDeepLink(uri, context);
  }

  /// Process pending deep link if user is logged in
  Future<void> processPendingDeepLink(BuildContext context) async {
    if (_pendingDeepLink == null || _isProcessing) return;

    _isProcessing = true;

    final isLoggedIn = await _checkIfUserLoggedIn();

    if (isLoggedIn) {
      await _processDeepLink(_pendingDeepLink!, context);
      _pendingDeepLink = null;
    } else {
      debugPrint('[DeepLink] User not logged in, skipping navigation');
    }

    _isProcessing = false;
  }

  /// Check if user is logged in
  Future<bool> _checkIfUserLoggedIn() async {
    final userDetailsJson = await Prefs.getString(PrefKeys.kUserDetails);
    final userDetails =
        LoginDetails.fromJson(json.decode(userDetailsJson ?? '{}'));
    return (userDetails.uid ?? '').haveContent();
  }

  /// Actual deep link navigation
  Future<void> _processDeepLink(Uri uri, BuildContext context) async {
    final path = uri.path.replaceFirst('/', '');
    debugPrint('DeepLink -> Path: $path, QueryParams: ${uri.queryParameters}');

    final currentStack =
        context.router.stack.map((route) => route.name).toList();

    if (path == ChatRoute.name) {
      // Ensure HomeRoute exists in the stack
      if (!currentStack.contains(HomeRoute.name)) {
        await context.router.replaceAll([
          const HomeRoute(),
          const ChatRoute(),
        ]);
      } else {
        if (currentStack.last != ChatRoute.name) {
          await context.router.push(const ChatRoute());
        }
      }
    } else {
      debugPrint('Unhandled deep link path: $path');
    }

    // Clear pending deep link after processing
    _pendingDeepLink = null;
  }
}
