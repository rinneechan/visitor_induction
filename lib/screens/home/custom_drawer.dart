import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

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
      nameRole = box.get('name_role', defaultValue: 'Visitor');
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

          // Daftar menu
          Expanded(
            child: ListView(
              children: [
                // Username
                ListTile(
                  title: Text(widget.username ?? 'Visitor'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // Role
                ListTile(
                  title: Text(nameRole ?? '-'),
                  leading: const Icon(Icons.badge),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                // Hanya tampil jika bukan Visitor
                if (nameRole != null && nameRole != 'visitorr') ...[
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
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildLogOutButton(context)),
      ],
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go('/logout');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDDDDDD),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.logout,
            color: Color(0xFF4F4D4D),
            size: 24.0,
          ),
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
}
