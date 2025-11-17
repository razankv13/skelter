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
      _pendingDeepLink = uri;
      debugPrint('[DeepLink] Context not ready, storing deep link');
      return;
    }

    await _handleDeepLink(uri, context);
  }

  Future<void> handlePendingDeepLink(BuildContext context) async {
    if (_pendingDeepLink == null || _isProcessingDeepLink) return;

    _isProcessingDeepLink = true;
    try {
      await _handleDeepLink(_pendingDeepLink!, context);
    } finally {
      _pendingDeepLink = null;
      _isProcessingDeepLink = false;
    }
  }

  Future<void> _handleDeepLink(Uri uri, BuildContext context) async {
    final segments = uri.pathSegments;

    if (segments.length < 2) {
      debugPrint('[DeepLink] Invalid path: $uri');
      return;
    }

    final routeSegment = segments[0].toLowerCase();
    final productId = segments[1];
    final router = context.router;

    const routeMap = {
      'product-detail': ProductDetailRoute.name,
      'home': HomeRoute.name,
    };

    final routeName = routeMap[routeSegment];
    if (routeName == null) {
      debugPrint('[DeepLink] Unhandled route: $routeSegment');
      return;
    }

    debugPrint('[DeepLink] route=$routeName, productId=$productId');

    final currentRoute = router.current;
    if (currentRoute.name == ProductDetailRoute.name &&
        currentRoute.args is ProductDetailRouteArgs &&
        (currentRoute.args! as ProductDetailRouteArgs).productId == productId) {
      debugPrint(
        '[DeepLink] Already on product $productId, skipping navigation',
      );
      return;
    }

    // App cold start from deep link: reset navigation stack
    if (!router.stack.any((route) => route.name == HomeRoute.name)) {
      await router.replaceAll([
        const HomeRoute(),
        ProductDetailRoute(productId: productId),
      ]);
      return;
    }

    // App already running: check and navigate safely to product detail
    router.popUntilRouteWithName(HomeRoute.name);
    await router.push(ProductDetailRoute(productId: productId));
  }
}
