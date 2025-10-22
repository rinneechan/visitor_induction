import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:she_vi/screens/setting/navigator_service.dart';
import 'package:flutter/foundation.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint("✅ Permission granted for notifications.");
      } else {
        debugPrint("❌ Permission denied for notifications.");
        return;
      }

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint("🔥 FCM Token: $token");
      }

      // Foreground notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("🔔 Foreground Message: ${message.notification?.title}");
        debugPrint("📦 Data: ${message.data}");

        if (message.data.isNotEmpty) {
          NavigatorService.navigateTo('/yourRoute'); // Perbaikan rute
        }
      });

      // Background notification (App dibuka melalui notifikasi)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            "🔔 Background Message opened: ${message.notification?.title}");
        NavigatorService.navigateTo('/yourRoute');
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } catch (e) {
      debugPrint("❌ Error in Firebase notification initialization: $e");
    }
  }

  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    debugPrint(
        "🔔 Background message received: ${message.notification?.title}");
  }
}
