import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();

    // Menunda perpindahan ke halaman berikutnya dengan memastikan context siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, '/choose-access');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
              fit: BoxFit.cover,
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
                    color: const Color(0xFF07840B),
                    fontFamily: 'Hanken Grotesk', // Pastikan font ini tersedia
                    height: 1.0,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                const Text(
                  'SHE PORTAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF07840B),
                  ),
                ),
                const SizedBox(height: 20),
                // Indikator loading
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
