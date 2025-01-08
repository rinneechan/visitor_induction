import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Pastikan file WelcomeScreen benar
import 'utils/app_route.dart'; // Pastikan AppRoutes diimplementasikan dengan benar
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive dan buka box
  try {
    await Hive.initFlutter();
    await Hive.openBox('userBox');
  } catch (e) {
    debugPrint('Error initializing Hive: $e');
  }

  // Memuat file .env
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHE Visitor Induction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Awali dengan WelcomeScreen
      routes: AppRoutes.getRoutes(), // Gunakan rute dari AppRoutes
    );
  }
}
