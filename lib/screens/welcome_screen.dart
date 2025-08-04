import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Tambahkan import GoRouter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Box box;
  String? username;
  String? visitorid;
  String? email;

  @override
  void initState() {
    super.initState();
    _openBox();
    // Menunda perpindahan ke halaman berikutnya dengan memastikan context siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () async {
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (isLoggedIn) {
          //Navigator.pushReplacementNamed(context, '/main-menu');
          //context.go('/main-menu');
          GoRouter.of(context).go('/request-induction',
              extra: {'username': username ?? 'defaultID'});
        } else {
          //context.go('/login');
          context.go('/choose-access');
        }
      });
    });
  }
  // Future<void> _openBox() async {
  //   box = await Hive.openBox('userBox');
  //   if (!mounted) return;
  //   setState(() {
  //     username = box.get('username');
  //     visitorid = box.get('visitorid');
  //     email = box.get('email');
  //     String? token = box.get('token');
  //     if (token == null || token.isEmpty) {
  //       Navigator.pushReplacementNamed(context, '/');
  //     }
  //   });
  // }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    if (!mounted) return;

    String? token = box.get('token');

    if (token == null || token.isEmpty) {
      // Pindahkan navigator ke luar `setState`
      if (mounted) {
        //Navigator.pushReplacementNamed(context, '/');
        GoRouter.of(context).go('/');
      }
    } else {
      setState(() {
        username = box.get('username');
        visitorid = box.get('visitorid');
        email = box.get('email');
      });
    }
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
          Positioned(
            top: 24, // Jarak dari atas, bisa disesuaikan
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/logo-cg.svg',
                  height: 30.0,
                  width: 45.0,
                  placeholderBuilder: (context) => CircularProgressIndicator(),
                ),
                SizedBox(width: 10),
                Image.asset(
                  'assets/images/Logo-badak.png',
                  width: 40.0,
                  height: 35.0,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 40.0),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'VISITOR INDUCTION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: const Color(
                        0xFF07840B), // Sesuai dengan --products-sedia-0-base
                    fontFamily: 'Hanken Grotesk', // Pastikan font ini tersedia
                    height: 0.85, // Sesuai dengan line-height 85%
                    fontStyle: FontStyle.normal,
                    letterSpacing: -2.8,
                  ),
                ),
                SizedBox(height: 6),
                const Text(
                  'SHE TRAINING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(
                        0xFFA4A4A4), // Sesuai dengan --Neutrals-500-placeholder, #A4A4A4
                    fontFamily: 'Hanken Grotesk', // Pastikan font ini tersedia
                    height: 1.0, // Sesuai dengan line-height 100%
                    fontStyle: FontStyle.normal,
                    letterSpacing: 8.4,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16, // Jarak dari bawah, bisa disesuaikan sesuai kebutuhan
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'version 0.0.1',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(
                        0xFFA4A4A4), // Sesuai dengan --Neutrals-500-placeholder, #A4A4A4
                    fontFamily: 'Hanken Grotesk',
                    height: 1.0,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 2.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
