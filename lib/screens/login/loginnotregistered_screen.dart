import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginNotRegistered extends StatefulWidget {
  @override
  _LoginNotRegisteredScreenState createState() =>
      _LoginNotRegisteredScreenState();
}

class _LoginNotRegisteredScreenState extends State<LoginNotRegistered> {
  //final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isPasswordVisible = false;

  void _login() {
    // String username = _usernameController.text;
    // String password = _passwordController.text;

    // // Simple validation and login logic
    // if (username == 'admin' && password == 'password') {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Login Successful'),
    //   ));
    //   // Navigate to another screen or perform any other action
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Invalid Username or Password'),
    //   ));
    // }
    print("Login button pressed");
  }

  @override
  void initState() {
    super.initState();
    // Tambahkan listener ke controller untuk mengecek setiap kali ada perubahan pada teks
    _passwordController.addListener(_checkIfButtonShouldBeEnabled);
  }

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      // Aktifkan tombol jika kedua field (nik) tidak kosong
      _isButtonEnabled = _passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sedia', // Teks di sebelah logo
              style: TextStyle(
                fontSize: 32.323, // Ukuran font
                fontWeight: FontWeight.w900, // Berat font
                color: Color(0xFFA4A4A4), // Warna placeholder
                height: 1.0, // Line-height
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min, // Important to limit width
              children: [
                SvgPicture.asset(
                  'assets/images/logo-cg.svg',
                  height: 40,
                ),
                SizedBox(width: 10),
                Image.asset(
                  'assets/images/Logo-badak.png',
                  height: 40,
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          // Gambar background, pastikan gambar ini memenuhi seluruh layar
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackgroundSedia.png', // Pastikan gambar ini sudah ada di folder assets
              fit: BoxFit.cover, // Mengatur gambar agar memenuhi layar
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 100.0,
                        left: 24.0,
                        right: 15.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Mengatur posisi teks ke kiri
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 7, 132, 11),
                              fontFamily: 'Hanken Grotesk',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'SEDIA Apps',
                            style: TextStyle(
                              fontSize: 40.0,
                              color: Color.fromARGB(255, 7, 132, 11),
                              fontFamily: 'Hanken Grotesk',
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          SizedBox(height: 16), // Jarak antara dua teks

                          // Jarak antara dua teks
                          Text(
                            'Please provide your account details.',
                            style: TextStyle(
                              color: const Color.fromARGB(
                                  255, 117, 117, 117), // Warna dari #757575
                              fontFamily: 'Hanken Grotesk', // Font-family
                              fontSize: 16.0, // Ukuran font
                              fontStyle: FontStyle.normal, // Font-style normal
                              fontWeight:
                                  FontWeight.w400, // Berat font (400 = normal)
                              height: 1.0, // Line-height (normal)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
