import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_update/in_app_update.dart';
import 'route/app_route.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:she_vi/screens/setting/navigator_service.dart';
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCqm_edaM0Aji-8JVSOj0GZ84Vxw-bv5WE",
          authDomain: "sedia-567ad.firebaseapp.com",
          projectId: "sedia-567ad",
          storageBucket: "sedia-567ad.appspot.com",
          messagingSenderId: "549508688373",
          appId: "1:549508688373:web:72dd0ad4b04ba50e5998bc",
          measurementId: "G-LVHCN4F385",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    //debugPrint("✅ Firebase initialized successfully");
  } catch (e) {
    //debugPrint("❌ Error initializing Firebase: $e");
  }

  try {
    await Hive.initFlutter();
    await Hive.openBox('userBox');
    debugPrint("✅ Hive initialized and 'userBox' opened");
  } catch (e) {
    debugPrint('❌ Error initializing Hive: $e');
  }

  // try {
  //   //await dotenv.load(fileName: 'assets/env');
  //   await dotenv.load(fileName: ".env");
  // } catch (e) {
  //   debugPrint('❌ Error membaca env file: $e');
  // }

  await FirebaseNotificationService().initNotifications();
  await AppUpdateService().checkForUpdate();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      //navigatorKey: globalNavigatorKey,
      builder: (context, child) => Navigator(
        //key: globalNavigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => child!,
        ),
      ),
    );
  }
}

// Layanan Firebase untuk menangani notifikasi
class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
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

      _initLocalNotifications();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //debugPrint("🔔 Foreground Message: ${message.notification?.title}");
        debugPrint("🔔 Notifikasi dibuka dari background: ${message.data}");
        _showForegroundNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } catch (e) {
      debugPrint("❌ Error in Firebase notification initialization: $e");
    }
  }

  // static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  //   debugPrint("🔔 Background message received: ${message.notification?.title}");
  // }
  Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    debugPrint("🔔 Background notifikasi diterima:");

    // Log bagian "notification"
    if (message.notification != null) {
      debugPrint("📌 Title: ${message.notification!.title}");
      debugPrint("📌 Body: ${message.notification!.body}");
    }

    // Log bagian "data"
    if (message.data.isNotEmpty) {
      debugPrint("📦 Data: ${message.data}");
    }
  }


  void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidSettings);

    _localNotifications.initialize(initializationSettings);
  }

  void _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: message.data['route'],
    );
  }

}
void _handleNotificationClick(RemoteMessage message) {
  try {
    debugPrint("🔔 Data notifikasi diterima: ${message.data}");
    if (message.data.containsKey('type')) {
      String type = message.data['type'];
      switch (type) {
        case 'approval':
          String idRequest = message.data['idrequest'] ?? '0';
          if (idRequest != '0') {
            globalNavigatorKey.currentState?.pushNamed(
              '/detail-info',
              arguments: {'id': idRequest},
            );
          }
          break;

        case 'induction':
          globalNavigatorKey.currentState?.pushNamed(
            '/request-induction',
            arguments: {'username': 'defaultID'},
          );
          break;

        default:
          globalNavigatorKey.currentState?.pushNamed('/home');
          break;
      }
    }
  } catch (e) {
    debugPrint("❌ Error handling notification click: $e");
  }
}


class AppUpdateService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> checkForUpdate() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.fetchAndActivate();

      final String latestVersion = _remoteConfig.getString('latest_version');
      //debugPrint("🔍 Latest Version from Firebase: $latestVersion");
      final bool forceUpdate = _remoteConfig.getBool('force_update');
      final String updateUrl = _remoteConfig.getString('update_url');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      if (_isNewVersionAvailable(currentVersion, latestVersion)) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          _checkAndroidUpdate(forceUpdate, updateUrl);
        } else {
          _showUpdateDialog(forceUpdate, updateUrl);
        }
      }
    } catch (e) {
      debugPrint("❌ Error checking app update: $e");
    }
  }

  bool _isNewVersionAvailable(String currentVersion, String latestVersion) {
    List<String> current = currentVersion.split('.');
    List<String> latest = latestVersion.split('.');

    for (int i = 0; i < latest.length; i++) {
      int currentValue = int.tryParse(current[i] ?? '0') ?? 0;
      int latestValue = int.tryParse(latest[i] ?? '0') ?? 0;

      debugPrint("Comparing version part: $currentValue vs $latestValue");

      if (latestValue > currentValue) {
        return true;
      } else if (latestValue < currentValue) {
        return false;
      }
    }
    return false;
  }

  void _checkAndroidUpdate(bool forceUpdate, String updateUrl) async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate().catchError((e) {
            debugPrint("❌ Immediate update failed: $e");
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate().catchError((e) {
            debugPrint("❌ Flexible update failed: $e");
          });
        }
      } else {
        _showUpdateDialog(forceUpdate, updateUrl);
      }
    } catch (e) {
      debugPrint("❌ Error checking Android update: $e");
      _showUpdateDialog(forceUpdate, updateUrl);
    }
  }

  void _showUpdateDialog(bool forceUpdate, String updateUrl) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: globalNavigatorKey.currentContext!,
        barrierDismissible: !forceUpdate,
        builder: (context) => AlertDialog(
          title: const Text('Pembaruan Tersedia'),
          content: const Text('Versi terbaru aplikasi telah tersedia. Harap perbarui aplikasi Anda.'),
          actions: [
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse(updateUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('❌ Gagal membuka URL pembaruan');
                }
              },
              child: const Text('Perbarui Sekarang'),
            ),
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Nanti'),
              ),
          ],
        ),
      );
    });
  }
}


// Future<void> _setupFirebaseNotification() async {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     _handleNotificationClick(message);
//   });
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     _handleNotificationClick(message);
//   });
//
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       _handleNotificationClick(message);
//     }
//   });
// }
