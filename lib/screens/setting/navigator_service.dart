import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigatorService {
  static BuildContext? get currentContext =>
      globalNavigatorKey.currentContext;

  static void navigateTo(String routeName) {
    if (currentContext != null) {
      GoRouter.of(currentContext!).go(routeName);
    } else {
      debugPrint("❌ Error: No context available for navigation.");
    }
  }
}

// GlobalKey untuk mendapatkan context aplikasi
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();
