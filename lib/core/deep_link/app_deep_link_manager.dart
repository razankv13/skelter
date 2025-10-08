import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:skelter/main.dart';
import 'package:skelter/routes.gr.dart';

class AppDeepLinkManager {
  AppDeepLinkManager._internal();
  static final AppDeepLinkManager _instance = AppDeepLinkManager._internal();
  static AppDeepLinkManager get instance => _instance;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _linkStreamSubscription;
  Uri? _pendingDeepLink;
  bool _isProcessingDeepLink = false;

  bool get hasPendingDeepLink => _pendingDeepLink != null;

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

  Future<void> _handleRuntimeDeepLink(Uri? uri) async {
    if (uri == null) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      // Context not ready → store deep link
      _pendingDeepLink = uri;
      debugPrint('[DeepLink] Context not ready, storing deep link');
      return;
    }

    // Context ready → process deep link
    await _processDeepLink(uri, context);
  }

  Future<void> handlePendingDeepLink(BuildContext context) async {
    if (_pendingDeepLink == null || _isProcessingDeepLink) return;

    _isProcessingDeepLink = true;
    try {
      await _processDeepLink(_pendingDeepLink!, context);
    } finally {
      _pendingDeepLink = null;
      _isProcessingDeepLink = false;
    }
  }

  Future<void> _processDeepLink(Uri uri, BuildContext context) async {
    try {
      final path = uri.path.replaceFirst('/', '');
      debugPrint(
        'DeepLink -> Path: $path, QueryParams: ${uri.queryParameters}',
      );

      final currentStack =
          context.router.stack.map((route) => route.name).toList();

      if (path == ChatRoute.name) {
        if (!currentStack.contains(HomeRoute.name)) {
          await context.router.replaceAll([
            const HomeRoute(),
            const ChatRoute(),
          ]);
        } else if (currentStack.last != ChatRoute.name) {
          await context.router.push(const ChatRoute());
        }
      } else {
        debugPrint('Unhandled deep link path: $path');
      }
    } catch (e) {
      debugPrint('[AppDeepLinkManager] : Error processing deep link: $e');
    } finally {
      _pendingDeepLink = null;
    }
  }
}
