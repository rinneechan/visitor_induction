import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:go_router/go_router.dart';
import 'route/app_route.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:she_vi/screens/setting/navigator_service.dart';
import 'package:she_vi/utils/env_helper.dart'; // Import helper
import 'package:she_vi/screens/home/custom_drawer.dart';

// Fungsi global untuk menangani notifikasi di background
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    debugPrint("🔔 Background notifikasi:");
    if (message.notification != null) {
      debugPrint("📌 Title: ${message.notification!.title}");
      debugPrint("📌 Body: ${message.notification!.body}");
    }
    if (message.data.isNotEmpty) {
      debugPrint("📦 Data: ${message.data}");
    }
    if (message.data.containsKey('route')) {
      globalNavigatorKey.currentState?.pushNamed(
        message.data['route'],
        arguments: message.data,
      );
    }
  } catch (e) {
    debugPrint("❌ Error handling background notification: $e");
  }
}

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
    await EnvHelper.loadEnv(); // Load env.json
  } catch (e) {
    debugPrint("❌ Error initializing Firebase: $e");
  }

  try {
    await Hive.initFlutter();
    await Hive.openBox('userBox');
    debugPrint("✅ Hive initialized and 'userBox' opened");
  } catch (e) {
    debugPrint('❌ Error initializing Hive: $e');
  }

  // Inisialisasi layanan Firebase Notification
  await FirebaseNotificationService().initNotifications();
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint("🔔 [Terminated] Notifikasi dibuka:");
    debugPrint("📌 Title: ${initialMessage.notification?.title}");
    debugPrint("📌 Body: ${initialMessage.notification?.body}");
    debugPrint("📦 Payload: ${initialMessage.data}");

    if (initialMessage.data.containsKey('route')) {
      String route = initialMessage.data['route'];
      String idRequest = initialMessage.data['id'] ?? 'defaultID';

      Future.delayed(Duration(milliseconds: 500), () {
        if (globalNavigatorKey.currentContext != null) {
          if (initialMessage.data['screen'] == 'EmailApproval') {
            globalNavigatorKey.currentContext!
                .go('/visitor-request?id=${initialMessage.data['id']}');
          } else {
            globalNavigatorKey.currentContext!.go('$route?id=$idRequest');
          }
        } else {
          debugPrint("⚠️ Context null, tidak bisa navigasi.");
        }
      });
    } else {
      debugPrint("⚠️ Tidak ada 'route' dalam data notifikasi");
    }
  }

  // Cek pembaruan aplikasi
  await AppUpdateService().checkForUpdate();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("✅ Notifikasi Diklik: ${message.data}");
      if (message.data.containsKey('route')) {
        String route = message.data['route'];
        String idRequest = message.data['id'] ?? 'defaultID';

        // Tambahkan logika untuk menangani navigasi lebih dari satu notifikasi
        Future.delayed(Duration(milliseconds: 500), () {
          if (globalNavigatorKey.currentContext != null) {
            if (message.data['screen'] == 'EmailApproval') {
              globalNavigatorKey.currentContext!
                  .go('/visitor-request?id=${message.data['id']}');
            } else {
              // Navigasi ke route lain
              globalNavigatorKey.currentContext!.go('$route?id=$idRequest');
            }
          } else {
            debugPrint("⚠️ Context null, tidak bisa navigasi.");
          }
        });
      } else {
        debugPrint("⚠️ Tidak ada 'route' dalam data notifikasi");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      builder: (context, child) => Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => child!,
        ),
      ),
    );
  }
}

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
      //if (token != null) {
      // debugPrint("🔥 FCM Token: $token");
      // }
      _initLocalNotifications();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            "🔔 [Foreground] Notifikasi diterima: ${message.notification?.title}");
        debugPrint("📦 Payload: ${message.data}");
        _showForegroundNotification(message);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      // Tangani notifikasi ketika aplikasi dalam keadaan terminated
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            "🔔 [Terminated] Notifikasi diklik saat aplikasi belum berjalan");
        _handleNotificationClick(initialMessage);
      }
    } catch (e) {
      debugPrint("❌ Error in Firebase notification initialization: $e");
    }
  }

  // Menangani klik notifikasi untuk navigasi
  void _handleNotificationClick(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      String route = message.data['route'];
      String idRequest = message.data['id'] ?? 'defaultID';

      // Delay untuk memastikan navigator siap
      Future.delayed(Duration(milliseconds: 500), () {
        if (globalNavigatorKey.currentContext != null) {
          if (message.data['screen'] == 'EmailApproval') {
            globalNavigatorKey.currentContext!
                .go('/visitor-request?id=${message.data['id']}');
          } else {
            globalNavigatorKey.currentContext!.go('$route?id=$idRequest');
          }
        } else {
          debugPrint("⚠️ Context null, tidak bisa navigasi.");
        }
      });
    } else {
      debugPrint("⚠️ Tidak ada 'route' dalam data notifikasi");
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
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: message.data['route'],
    );
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
      final bool forceUpdate = _remoteConfig.getBool('force_update');
      final String updateUrl = _remoteConfig.getString('update_url');

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // ✅ Tambahkan Debug Print di sini
      debugPrint("🔍 Versi Saat Ini: $currentVersion");
      debugPrint("🔍 Versi Terbaru dari Remote Config: $latestVersion");
      debugPrint("🔍 Apakah Update Paksa: $forceUpdate");
      debugPrint("🔍 URL Update: $updateUrl");

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
      int currentValue = int.tryParse(current[i]) ?? 0;
      int latestValue = int.tryParse(latest[i]) ?? 0;

      if (latestValue > currentValue) {
        return true;
      } else if (latestValue < currentValue) {
        return false;
      }
    }
    return false;
  }

  // void _checkAndroidUpdate(bool forceUpdate, String updateUrl) async {
  //   try {
  //     final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

  //     if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
  //       if (updateInfo.immediateUpdateAllowed) {
  //         await InAppUpdate.performImmediateUpdate().catchError((e) {
  //           debugPrint("❌ Immediate update failed: $e");
  //         });
  //       } else if (updateInfo.flexibleUpdateAllowed) {
  //         await InAppUpdate.startFlexibleUpdate().catchError((e) {
  //           debugPrint("❌ Flexible update failed: $e");
  //         });
  //       }
  //     } else {
  //       _showUpdateDialog(forceUpdate, updateUrl);
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Error checking Android update: $e");
  //     _showUpdateDialog(forceUpdate, updateUrl);
  //   }
  // }
  void _checkAndroidUpdate(bool forceUpdate, String updateUrl) async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          try {
            await InAppUpdate.performImmediateUpdate();
          } catch (e) {
            debugPrint("❌ Immediate update failed: $e");
          }
        } else if (updateInfo.flexibleUpdateAllowed) {
          try {
            await InAppUpdate.startFlexibleUpdate();
          } catch (e) {
            debugPrint("❌ Flexible update failed: $e");
          }
        }
      } else {
        // Tidak ada update, bisa tampilkan dialog jika perlu
        _showUpdateDialog(forceUpdate, updateUrl);
      }
    } catch (e) {
      debugPrint("❌ Error checking Android update: $e");
      _showUpdateDialog(forceUpdate, updateUrl);
    }
  }

  void _showUpdateDialog(bool forceUpdate, String? updateUrl) {
    if (globalNavigatorKey.currentContext == null) {
      debugPrint("❌ Context is null, cannot show update dialog.");
      return;
    }

    if (updateUrl == null || updateUrl.isEmpty) {
      debugPrint("❌ URL pembaruan tidak valid atau kosong");
      return;
    }

    try {
      final Uri url = Uri.parse(updateUrl);
      debugPrint('✅ URL Valid: $url');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: globalNavigatorKey.currentContext!,
          barrierDismissible: !forceUpdate,
          builder: (context) => AlertDialog(
            title: const Text('Pembaruan Tersedia'),
            content: const Text(
                'Versi terbaru aplikasi telah tersedia. Harap perbarui aplikasi Anda.'),
            actions: [
              TextButton(
                onPressed: () async {
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
    } catch (e) {
      debugPrint('❌ Error saat parsing URL: $e');
    }
  }
}

// void _showUpdateDialog(bool forceUpdate, String updateUrl) {
//   if (globalNavigatorKey.currentContext == null) {
//     debugPrint("❌ Context is null, cannot show update dialog.");
//     return;
//   }
//
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     showDialog(
//       context: globalNavigatorKey.currentContext!,
//       barrierDismissible: !forceUpdate,
//       builder: (context) => AlertDialog(
//         title: const Text('Pembaruan Tersedia'),
//         content: const Text('Versi terbaru aplikasi telah tersedia. Harap perbarui aplikasi Anda.'),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               final Uri url = Uri.parse(updateUrl);
//               if (await canLaunchUrl(url)) {
//                 await launchUrl(url, mode: LaunchMode.externalApplication);
//               } else {
//                 debugPrint('❌ Gagal membuka URL pembaruan');
//               }
//             },
//             child: const Text('Perbarui Sekarang'),
//           ),
//           if (!forceUpdate)
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Nanti'),
//             ),
//         ],
//       ),
//     );
//   });
// }
