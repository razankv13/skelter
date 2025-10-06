import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:skelter/main.dart';
import 'package:skelter/routes.gr.dart';

class AppDeepLinkManager {
  AppDeepLinkManager._();

  static final AppDeepLinkManager _instance = AppDeepLinkManager._();

  static AppDeepLinkManager get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _streamSubscription;

  Future<void> initialize() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      await _handleDeepLink(initialUri);

      _streamSubscription = _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (err) => debugPrint('[AppDeepLinkManager] Error: $err'),
        onDone: () => _streamSubscription?.cancel(),
      );

      debugPrint('[AppDeepLinkManager] Listener initialized.');
    } on PlatformException catch (e) {
      debugPrint('[AppDeepLinkManager] PlatformException: $e');
    }
  }

  /// Process an incoming deep link
  Future<void> _handleDeepLink(Uri? uri) async {
    if (uri == null) {
      debugPrint('[AppDeepLinkManager] Received null URI');
      return;
    }

    debugPrint(
      '[AppDeepLinkManager] Deep link: path=${uri.path}, '
      'query=${uri.queryParameters}',
    );

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('[AppDeepLinkManager] Navigator context is null');
      return;
    }

    final path = uri.path.replaceFirst('/', '');

    switch (path) {
      case ChatRoute.name:
        await context.pushRoute(const ChatRoute());

      // TODO: Add additional deep link cases here

      default:
        debugPrint('[AppDeepLinkManager] Unhandled path: ${uri.path}');
    }
  }
}
