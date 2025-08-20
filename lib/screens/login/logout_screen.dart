import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Hapus data auth Firebase
      await FirebaseAuth.instance.signOut();

      // Hapus data Hive
      var userBox = await Hive.openBox('userBox');
      await userBox.clear();

      // Hapus SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Arahkan ke login setelah logout
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint("❌ Error saat logout: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal logout: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logout")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          label: const Text("Keluar"),
        ),
      ),
    );
  }
}
