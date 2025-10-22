// lib/screens/setting/navigator_service.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔑 GlobalKey untuk navigator
final globalNavigatorKey = GlobalKey<NavigatorState>();

class NavigatorService {
  static BuildContext? get currentContext => globalNavigatorKey.currentContext;

  // 🔁 Kita kembalikan nama ke `navigateTo` agar tidak error
  static void navigateTo(String path, {Object? extra}) {
    final context = currentContext;
    if (context != null) {
      context.go(path, extra: extra);
    } else {
      debugPrint('❌ Tidak bisa navigasi: context tidak tersedia. Path: $path');
    }
  }

  // Opsional: tetap sediakan pushNamed untuk background
  static void pushNamed(String route, {Object? arguments}) {
    final nav = globalNavigatorKey.currentState;
    if (nav != null) {
      nav.pushNamed(route, arguments: arguments);
    }
  }
}
