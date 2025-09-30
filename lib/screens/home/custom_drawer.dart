import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  final String? username;

  const CustomDrawer({Key? key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Bagian header
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
                  fontStyle: FontStyle.normal,
                  height: 1.0,
                ),
              ),
            ),
          ),
          // Bagian item menu
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(username ?? 'Visitor'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Settings'),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
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
                    context.go('/cms'); // cuma redirect ke dashboard CMS
                  },
                ),
              ],
            ),
          ),
          // Bagian tombol logout
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: _buildButtons(context),
          ),
        ],
      ),
    );
  }

  // Membuat tombol-tombol
  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildLogOutButton(context)),
      ],
    );
  }

  // Tombol logout redirect ke logout_screen.dart
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
