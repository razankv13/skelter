import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:skelter/main.dart';
import 'package:skelter/routes.gr.dart';

class AppDeepLinkManager {
  AppDeepLinkManager._internal();

  static final AppDeepLinkManager instance = AppDeepLinkManager._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _linkSubscription;
  Uri? _pendingDeepLink;
  bool _isProcessingDeepLink = false;

  bool get hasPendingDeepLink => _pendingDeepLink != null;

  Future<void> initializeDeepLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _pendingDeepLink = initialUri;

      _linkSubscription = _appLinks.uriLinkStream.listen(
        _onRuntimeDeepLinkReceived,
        onError: (err) => debugPrint('[DeepLink] Error: $err'),
        onDone: disposeDeepLinkListener,
      );
    } on PlatformException catch (e) {
      debugPrint('[DeepLink] PlatformException: $e');
    }
  }

  Future<void> _onRuntimeDeepLinkReceived(Uri? uri) async {
    if (uri == null) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _pendingDeepLink = uri;
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
    if (segments.length < 2) return;

    final routeKey = segments[0].toLowerCase();
    final routeArg = segments[1];

    final router = context.router;
    final routeName = _deepLinkRoutes[routeKey];

    if (routeName == null) return;

    if (_isOnProductDetail(router, routeArg)) return;

    await _navigateToProductDetail(router, routeArg);
  }

  final Map<String, String> _deepLinkRoutes = {
    'product-detail': ProductDetailRoute.name,
    'home': HomeRoute.name,
  };

  bool _isOnProductDetail(StackRouter router, String productId) {
    final current = router.current;
    return current.name == ProductDetailRoute.name &&
        current.args is ProductDetailRouteArgs &&
        (current.args! as ProductDetailRouteArgs).productId == productId;
  }

  Future<void> _navigateToProductDetail(
    StackRouter router,
    String productId,
  ) async {
    if (!router.stack.any((route) => route.name == HomeRoute.name)) {
      await router.replaceAll([
        const HomeRoute(),
        ProductDetailRoute(productId: productId),
      ]);
      return;
    }

    router.popUntilRouteWithName(HomeRoute.name);
    await router.push(ProductDetailRoute(productId: productId));
  }

  void disposeDeepLinkListener() => _linkSubscription?.cancel();
}
