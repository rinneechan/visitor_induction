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
import 'package:she_vi/utils/env_helper.dart';
import 'package:provider/provider.dart';
import 'package:she_vi/screens/external/page/user_profile.dart'; // Provider UserProfile

// =============== HANDLER NOTIFIKASI ===============

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    debugPrint("🔔 [Background] Notifikasi diterima");
    if (message.data.containsKey('route')) {
      NavigatorService.pushNamed(
        message.data['route']!,
        arguments: message.data,
      );
    }
  } catch (e) {
    debugPrint("❌ Error di background handler: $e");
  }
}

void _handleNotificationNavigation(RemoteMessage message) {
  if (!message.data.containsKey('route')) {
    debugPrint("⚠️ Tidak ada 'route' dalam payload notifikasi");
    return;
  }

  final String route = message.data['route'];
  final String id = message.data['id'] ?? 'defaultID';
  final bool isEmailApproval = message.data['screen'] == 'EmailApproval';

  Future.delayed(const Duration(milliseconds: 500), () {
    if (isEmailApproval) {
      NavigatorService.navigateTo('/visitor-request?id=$id');
    } else {
      NavigatorService.navigateTo('$route?id=$id');
    }
  });
}

// =============== MAIN FUNCTION ===============

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Firebase
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
    await EnvHelper.loadEnv();
  } catch (e) {
    debugPrint("❌ Gagal inisialisasi Firebase: $e");
  }

  // 🔹 Inisialisasi Hive
  try {
    await Hive.initFlutter();
    await Hive.openBox('userBox');
    debugPrint("✅ Hive berhasil diinisialisasi");
  } catch (e) {
    debugPrint("❌ Gagal inisialisasi Hive: $e");
  }

  // 🔹 Daftarkan listener notifikasi
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

  // 🔹 Inisialisasi notifikasi
  await FirebaseNotificationService().init();

  // 🔹 Tangani notifikasi saat app terminated
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleNotificationNavigation(initialMessage);
  }

  // 🔹 Cek pembaruan aplikasi
  await AppUpdateService().checkForUpdate();

  // 🔹 Jalankan aplikasi dengan Provider UserProfile
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final profile = UserProfile();
        profile.loadPlantIdFromHive(); // otomatis load plantId
        return profile;
      },
      child: const MyApp(),
    ),
  );
}

// =============== APLIKASI UTAMA ===============

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// =============== LAYANAN NOTIFIKASI ===============

class FirebaseNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint("❌ Izin notifikasi ditolak");
        return;
      }

      _initLocalNotifications();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            "🔔 [Foreground] Notifikasi: ${message.notification?.title}");
        _showLocalNotification(message);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } catch (e) {
      debugPrint("❌ Gagal inisialisasi notifikasi: $e");
    }
  }

  void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    _localNotifications.initialize(initSettings);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? 'Anda memiliki notifikasi baru',
      details,
    );
  }
}

// =============== LAYANAN PEMBARUAN APLIKASI ===============

class AppUpdateService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> checkForUpdate() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();

      final String latestVersion = _remoteConfig.getString('latest_version');
      final bool forceUpdate = _remoteConfig.getBool('force_update');
      final String updateUrl = _remoteConfig.getString('update_url');

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      debugPrint(
          "🔍 Versi saat ini: $currentVersion | Terbaru: $latestVersion");

      if (_isNewVersionAvailable(currentVersion, latestVersion)) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          _checkAndroidUpdate(forceUpdate, updateUrl);
        } else {
          _showUpdateDialog(forceUpdate, updateUrl);
        }
      }
    } catch (e) {
      debugPrint("❌ Gagal cek pembaruan: $e");
    }
  }

  bool _isNewVersionAvailable(String current, String latest) {
    final List<String> currentParts = current.split('.');
    final List<String> latestParts = latest.split('.');

    for (int i = 0; i < 3; i++) {
      final int c = int.tryParse(currentParts[i] ?? '0') ?? 0;
      final int l = int.tryParse(latestParts[i] ?? '0') ?? 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  Future<void> _checkAndroidUpdate(bool forceUpdate, String updateUrl) async {
    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
        } else {
          _showUpdateDialog(forceUpdate, updateUrl);
        }
      }
    } catch (e) {
      debugPrint("❌ Gagal cek pembaruan Android: $e");
      _showUpdateDialog(forceUpdate, updateUrl);
    }
  }

  void _showUpdateDialog(bool forceUpdate, String updateUrl) {
    if (updateUrl.isEmpty || NavigatorService.currentContext == null) return;

    try {
      final Uri uri = Uri.parse(updateUrl);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: NavigatorService.currentContext!,
          barrierDismissible: !forceUpdate,
          builder: (context) => AlertDialog(
            title: const Text('Pembaruan Tersedia'),
            content: const Text(
                'Versi terbaru aplikasi telah tersedia. Harap perbarui aplikasi Anda.'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Perbarui Sekarang'),
              ),
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nanti'),
                ),
            ],
          ),
        );
      });
    } catch (e) {
      debugPrint("❌ Gagal tampilkan dialog pembaruan: $e");
    }
  }
}
