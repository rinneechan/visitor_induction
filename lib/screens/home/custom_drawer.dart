import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  final String? username;

  const CustomDrawer({Key? key, this.username}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? nameRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final box = await Hive.openBox('userBox');
    setState(() {
      nameRole = box.get('nameRole', defaultValue: 'Visitor');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Header
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 248, 249, 249),
            ),
            child: Center(
              child: Text(
                'Sedia',
                style: TextStyle(
                  color: Color(0xFF07840B),
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),

          // Menu list
          Expanded(
            child: ListView(
              children: [
                // Username
                ListTile(
                  title: Text(widget.username ?? 'Visitor'),
                  leading: const Icon(Icons.person),
                  onTap: () => Navigator.pop(context),
                ),

                // Role
                ListTile(
                  title: Text(nameRole ?? '-'),
                  leading: const Icon(Icons.badge),
                  onTap: () => Navigator.pop(context),
                ),

                const Divider(),

                // Visitor Induction Menu
                ListTile(
                  leading: const Icon(Icons.assignment_ind_outlined),
                  title: const Text("Visitor Induction"),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/employee/request-induction');
                  },
                ),

                // CMS Menu - hanya muncul jika bukan visitor
                if (nameRole != null &&
                    nameRole!.toLowerCase() != 'visitor') ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "CMS Menu",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard_customize),
                    title: const Text("CMS - Induction"),
                    onTap: () {
                      context.go('/cms');
                    },
                  ),
                ],
              ],
            ),
          ),

          // Tombol Logout
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(child: _buildLogoutButton(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _confirmLogout(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDDDDDD),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Color(0xFF4F4D4D), size: 24.0),
          SizedBox(width: 8),
          Text(
            'LOGOUT',
            style: TextStyle(
              color: Color(0xFF4F4D4D),
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 Konfirmasi sebelum logout
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // 🔸 Fungsi logout: hapus semua session & storage
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Tutup drawer kalau masih terbuka
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 1️⃣ Bersihkan SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2️⃣ Bersihkan semua data Hive, tapi jangan hapus box-nya
      if (await Hive.boxExists('userBox')) {
        final userBox = await Hive.openBox('userBox');
        await userBox.clear();
      }

      // 3️⃣ Pastikan tidak menutup atau menghapus box (biar tidak error setelah redirect)

      // 4️⃣ Redirect ke halaman login / choose-access
      if (context.mounted) {
        context.go('/choose-access');
      }

      debugPrint('✅ Logout berhasil, semua data lokal sudah dihapus.');
    } catch (e) {
      debugPrint('❌ Error saat logout: $e');
    }
  }
}
