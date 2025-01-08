import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();

    // Menunda perpindahan ke ChooseAccess setelah 5 detik
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(
          context, '/choose-access'); // Pindah ke ChooseAccess
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //title: Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          // Gambar background
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackgroundSedia.png', // Pastikan gambar ini sudah ada di folder assets
              fit: BoxFit.cover, // Mengatur gambar agar memenuhi layar
            ),
          ),
          // Konten di atas gambar
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Sedia',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF07840B), // Warna dari #07840B
                    fontFamily: 'Hanken Grotesk', // Font family Hanken Grotesk
                    height:
                        1.0, // Line height 100% atau sama dengan tinggi font
                    fontStyle: FontStyle.normal,
                  ),
                ),
                Text(
                  'SHE PORTAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 7, 132,
                        11), // Warna teks diubah agar kontras dengan background
                  ),
                ),
                SizedBox(height: 20),
                // CircularProgressIndicator(
                //   valueColor: AlwaysStoppedAnimation<Color>(
                //       Colors.white), // Indikator loading berwarna putih
                // ), // Indikator loading selama menunggu
              ],
            ),
          ),
        ],
      ),
    );
  }
}
