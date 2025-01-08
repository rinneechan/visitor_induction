import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String? username;

  const CustomDrawer({Key? key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Bagian header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 248, 249, 249),
            ),
            child: Center(
              child: Text(
                'Sedia',
                style: const TextStyle(
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
                  title: Text(username ?? 'Guest'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    // Navigasi saat item ditekan
                    Navigator.pop(context); // Menutup drawer
                  },
                ),
                ListTile(
                  title: const Text('Settings'),
                  leading: const Icon(Icons.settings),
                  onTap: () {
                    // Navigasi untuk settings
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Bagian tombol logout
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

  // Membuat tombol-tombol
  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLogOutButton(context),
      ],
    );
  }

  // Tombol logout
  Widget _buildLogOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Tambahkan logika logout di sini
        Navigator.pop(context); // Menutup drawer setelah logout
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDDDDDD), // Warna latar tombol
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding tombol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Radius border
          //side: const BorderSide(color: Color(0xFFDDDDDD)), // Border tombol
        ),
        alignment: Alignment.centerLeft, // Konten diatur ke kiri
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Konten sejajar vertikal
        mainAxisAlignment: MainAxisAlignment.start, // Konten sejajar horizontal
        children: const [
          Icon(
            Icons.logout, // Ikon logout
            color: Color(0xFF4F4D4D), // Warna ikon
            size: 24.0,
          ),
          SizedBox(width: 8), // Jarak antara ikon dan teks
          Text(
            'LOGOUT',
            style: TextStyle(
              color: Color(0xFF4F4D4D), // Warna teks
              fontFamily: 'Hanken Grotesk',
              fontSize: 16.0,
              fontWeight: FontWeight.w600, // Ketebalan teks
            ),
          ),
        ],
      ),
    );
  }
}
