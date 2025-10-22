import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:she_vi/services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../setting/firebase_notification_service.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;
  bool _isButtonPassEnabled = false;
  bool _isLoading = false;
  bool _showPopup = true;

  late Box box;
  String? username;
  String? visitorid;
  String? email;

  final ApiService _apiService = ApiService();

  bool _isTextFieldVisible = true;

  void OK_login() async {
    String username = _usernameController.text;
    if (username.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic>? userData = await _apiService.loginNik(username);

      setState(() {
        _isLoading = false;
      });
      debugPrint("Response userData: ${userData.toString()}"); // Debug output

      if (userData == null) {
        print('Status Code: ${_apiService.lastResponseStatusCode}');
        if (_apiService.lastResponseStatusCode == 401) {
          _showLoginError();
        } else if (_apiService.lastResponseStatusCode == 404) {
          _showLoginError();
        } else {
          _showConnectionError();
        }
      } else {
        if (_apiService.lastResponseStatusCode == 200) {
          setState(() {
            _isTextFieldVisible = !_isTextFieldVisible;
          });
        } else if (_apiService.lastResponseStatusCode == 400) {
          // Jika status 400, arahkan ke CreateNewPass
          context.go(
            '/create-new-pass/${userData['employee_id']}/${userData['full_name']}/${userData['email']}',
          );
        }
      }
    } else {
      _showLoginError();
    }
  }

  void _login() async {
    String username = _usernameController.text;
    if (username.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic>? userData = await _apiService.loginNik(username);

      // ✅ Tambahkan ini
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint("Response userData: ${userData.toString()}");

      if (userData == null) {
        print('Status Code: ${_apiService.lastResponseStatusCode}');
        if (_apiService.lastResponseStatusCode == 401) {
          _showLoginError();
        } else if (_apiService.lastResponseStatusCode == 404) {
          _showLoginError();
        } else {
          _showConnectionError();
        }
      } else {
        if (_apiService.lastResponseStatusCode == 200) {
          // ✅ Tambahkan ini
          if (!mounted) return;

          setState(() {
            _isTextFieldVisible = !_isTextFieldVisible;
          });
        } else if (_apiService.lastResponseStatusCode == 400) {
          context.go(
            '/create-new-pass/${userData['employee_id']}/${userData['full_name']}/${userData['email']}',
          );
        }
      }
    } else {
      _showLoginError();
    }
  }

  void _changeEmployeeId() {
    //_isTextFieldVisible = !_isTextFieldVisible;
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isTextFieldVisible = !_isTextFieldVisible;
      });
    });
  }

  void _showLoginError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Gagal'),
          content: Text('Username atau password yang Anda masukkan salah.'),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void OK_loginPass() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Periksa koneksi internet sebelum login
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          setState(() {
            _isLoading = false;
          });
          _showConnectionError();
          return;
        }

        String? fcmToken;

        if (kIsWeb) {
          fcmToken = 'shevi'; // Tandai bahwa aplikasi dijalankan di web
        } else {
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          fcmToken = await messaging.getToken();

          if (fcmToken == null) {
            debugPrint('❌ Gagal mendapatkan FCM token.');
          }
        }

        bool isLoginSuccessful =
            await _apiService.loginNikPass(username, password, fcmToken ?? '');

        setState(() {
          _isLoading = false;
        });

        if (isLoginSuccessful) {
          // Simpan status login
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', username);

          // Inisialisasi notifikasi setelah login berhasil
          await FirebaseNotificationService().initNotifications();

          GoRouter.of(context)
              .go('/employee/request-induction', extra: {'username': username});
        } else {
          _showLoginPassError(
            errorMessage: 'Login gagal. Harap periksa kembali kredensial Anda.',
          );
        }
      } on SocketException {
        setState(() {
          _isLoading = false;
        });
        debugPrint("❌ Tidak ada koneksi internet.");
        _showConnectionError();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("❌ Error saat login: $e");
        _showLoginPassError(errorMessage: e.toString());
      }
    } else {
      _showLoginPassError(
        errorMessage: 'Username dan password tidak boleh kosong.',
      );
    }
  }

  void _loginPass() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          setState(() {
            _isLoading = false;
          });
          _showConnectionError();
          return;
        }

        String? fcmToken;

        if (kIsWeb) {
          fcmToken = 'shevi'; // Tandai bahwa aplikasi dijalankan di web
        } else {
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          fcmToken = await messaging.getToken();

          if (fcmToken == null) {
            debugPrint('❌ Gagal mendapatkan FCM token.');
          }
        }

        bool isLoginSuccessful =
            await _apiService.loginNikPass(username, password, fcmToken ?? '');

        // ✅ Tambahkan ini sebelum setState
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (isLoginSuccessful) {
          // Simpan data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', username);

          // Inisialisasi notifikasi — ini bisa memicu setState setelah navigasi
          await FirebaseNotificationService().initNotifications();

          // Navigasi — setelah ini, LoginScreen akan di-unmount
          GoRouter.of(context)
              .go('/employee/request-induction', extra: {'username': username});
        } else {
          _showLoginPassError(
            errorMessage: 'Login gagal. Harap periksa kembali kredensial Anda.',
          );
        }
      } on SocketException {
        // ✅ Tambahkan ini juga
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
        debugPrint("❌ Tidak ada koneksi internet.");
        _showConnectionError();
      } catch (e) {
        // ✅ Tambahkan ini juga
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
        debugPrint("❌ Error saat login: $e");
        _showLoginPassError(errorMessage: e.toString());
      }
    } else {
      _showLoginPassError(
        errorMessage: 'Username dan password tidak boleh kosong.',
      );
    }
  }

  void _showLoginPassError(
      {String errorMessage = 'Username atau password salah.'}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Gagal'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConnectionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text(
            'Tidak dapat terhubung ke server. Periksa koneksi Anda.'),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool isMobileBrowser() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('iphone') ||
        userAgent.contains('android') ||
        userAgent.contains('ipad') ||
        userAgent.contains('mobile');
  }

  @override
  void initState() {
    super.initState();
    _showPopup = kIsWeb && isMobileBrowser();
    _usernameController.addListener(_checkIfButtonShouldBeEnabled);
    _passwordController.addListener(_checkIfButtonPassBeEnabled);
    _init();
  }

  Future<void> _init() async {
    await _openBox(); // Tunggu hingga box terbuka dan data dimuat
    //await _checkLoginStatus(); // Lanjutkan cek login setelah itu
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('userBox');
    if (!mounted) return; // ✅ Tambahkan ini

    final String? token = box.get('token');
    final String? username = box.get('username');
    final String? visitorid = box.get('visitorid');
    final String? email = box.get('email');

    if (token != null &&
        token.isNotEmpty &&
        username != null &&
        visitorid != null &&
        email != null) {
      // ✅ Tambahkan ini
      if (!mounted) return;

      setState(() {
        this.username = username;
        this.visitorid = visitorid;
        this.email = email;
      });

      GoRouter.of(context)
          .go('/request-induction', extra: {'username': username});
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      _isButtonEnabled = _usernameController.text.length >= 6;
    });
  }

  @override
  void _checkIfButtonPassBeEnabled() {
    setState(() {
      _isButtonPassEnabled = _passwordController.text.length >= 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final bodyWidth = MediaQuery.of(context).size.shortestSide;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final FocusNode usernameFocusNode = FocusNode();

    double fontSize(double mobile, double tablet, double web) => isMobile
        ? mobile
        : isTablet
            ? tablet
            : web;
    double elementSize(double mobile, double tablet, double web) => isMobile
        ? mobile
        : isTablet
            ? tablet
            : web;

    //final showPopup = kIsWeb && isMobileBrowser();
    //bool showPopup = kIsWeb && isMobileBrowser();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            return Center(
              child: Container(
                // Background Image Full Screen
                width: MediaQuery.of(context).size.shortestSide,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/BackgroundVI.png'),
                    fit: BoxFit.cover, // Gambar menutupi seluruh area
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: elementSize(16, 24, 32),
                                    horizontal: elementSize(16, 24, 32),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/logo-cg.svg',
                                            height: 30.0,
                                            width: 45.0,
                                            placeholderBuilder: (context) =>
                                                CircularProgressIndicator(),
                                          ),
                                          SizedBox(width: 10),
                                          Image.asset(
                                            'assets/images/Logo-badak.png',
                                            width: 40.0,
                                            height: 35.0,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(Icons.broken_image,
                                                        size: 40.0),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Welcome!',
                                        style: TextStyle(
                                          fontSize: 32.0,
                                          color:
                                              Color.fromARGB(255, 7, 132, 11),
                                          fontFamily: 'Hanken Grotesk',
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Please provide your account details.',
                                        style: TextStyle(
                                          color: const Color.fromARGB(255, 117,
                                              117, 117), // Warna dari #757575
                                          fontFamily:
                                              'Hanken Grotesk', // Font-family
                                          fontSize: 14.0, // Ukuran font
                                          fontStyle: FontStyle
                                              .normal, // Font-style normal
                                          fontWeight: FontWeight
                                              .w400, // Berat font (400 = normal)
                                          height: 1.0, // Line-height (normal)
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    'Employee ID',
                                    style: TextStyle(
                                      color: Color(0xFF343434),
                                      fontFamily: 'Hanken Grotesk',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Visibility(
                                    visible: _isTextFieldVisible,
                                    child: TextField(
                                      controller: _usernameController,
                                      focusNode: usernameFocusNode,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your employee id',
                                        // prefixIcon: Icon(Icons.person),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // Menampilkan Text jika _isTextFieldVisible false
                                  Visibility(
                                    visible:
                                        !_isTextFieldVisible, // Menyembunyikan saat _isTextFieldVisible true
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween, // Mengatur jarak antara teks dan tombol
                                      children: <Widget>[
                                        Text(
                                          _usernameController.text,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 79, 77, 77),
                                            fontFamily: 'Hanken Grotesk',
                                            fontSize: 16.0,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                          ),
                                        ),

                                        // Tombol "Change" di sebelah kanan
                                        ElevatedButton(
                                          onPressed: _changeEmployeeId,
                                          style: ButtonStyle(
                                            padding: WidgetStateProperty.all<
                                                    EdgeInsets>(
                                                EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 16)),
                                            backgroundColor: WidgetStateProperty
                                                .all<Color>(Color.fromARGB(
                                                    255,
                                                    248,
                                                    250,
                                                    248)), // Warna background
                                            shape: WidgetStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8), // Border-radius
                                                side: BorderSide(
                                                  color: Color(
                                                      0xFF07840B), // Warna border
                                                  width: 1, // Ketebalan border
                                                ),
                                              ),
                                            ),
                                            foregroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    const Color(0xFF07840B)),
                                            textStyle: WidgetStateProperty.all<
                                                TextStyle>(
                                              TextStyle(
                                                fontFamily: 'Hanken Grotesk',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                height: 1.56,
                                              ),
                                            ),
                                          ),
                                          child: Text('Change'),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  // TextField untuk password
                                  Visibility(
                                    visible:
                                        !_isTextFieldVisible, // Menyembunyikan saat _isTextFieldVisible false
                                    child: TextField(
                                      autofocus: false,
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      decoration: InputDecoration(
                                        //labelText: 'Enter your password',
                                        hintText: 'Enter your password',
                                        prefixIcon: Container(
                                          padding: EdgeInsets.only(
                                              right:
                                                  0), // Jarak antara garis dan teks
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color:
                                                    Colors.grey, // Warna garis
                                                width: 1.0, // Ketebalan garis
                                              ),
                                            ),
                                          ),
                                          child: Icon(Icons.lock,
                                              color: const Color.fromARGB(
                                                  255,
                                                  170,
                                                  171,
                                                  172)), // Ikon gembok
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16),
                                  Visibility(
                                    visible: _isTextFieldVisible,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Container(
                                        //   height: 56,
                                        //   decoration: BoxDecoration(
                                        //     border: Border.all(
                                        //       color: Colors.grey,
                                        //       width: 2.0,
                                        //     ),
                                        //     borderRadius: BorderRadius.circular(8.0), // Jika ingin border sudut melengkung
                                        //   ),
                                        //   child: IconButton(
                                        //     icon: Icon(Icons.arrow_back),
                                        //     //onPressed: () {Navigator.pop(context);},
                                        //       onPressed: () {context.go('/choose-access');}
                                        //   ),
                                        // ),
                                        // SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _isButtonEnabled
                                                ? _login
                                                : null,
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                                  if (states.contains(
                                                      WidgetState.disabled)) {
                                                    return Color(
                                                        0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                                  }
                                                  return Color(
                                                      0xFF07840B); // Warna saat tombol aktif
                                                },
                                              ),
                                              padding: WidgetStateProperty.all<
                                                  EdgeInsets>(
                                                EdgeInsets.symmetric(
                                                    vertical:
                                                        16.0), // Menyesuaikan padding agar tombol lebih tinggi
                                              ),
                                              minimumSize:
                                                  WidgetStateProperty.all<Size>(
                                                Size(double.infinity,
                                                    56), // Ukuran minimum tombol dengan tinggi 56
                                              ),
                                              shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Sama dengan border-radius: 8px;
                                                ),
                                              ),
                                              foregroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                                  if (states.contains(
                                                      WidgetState.disabled)) {
                                                    return Colors.white;
                                                  }
                                                  return Colors.white;
                                                },
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center, // Sama dengan justify-content: center;
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center, // Sama dengan align-items: center;
                                              children: [
                                                SizedBox(
                                                    width:
                                                        10), // Sama dengan gap: 16px
                                                Text(
                                                  'Continue',
                                                  style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 79, 77, 77),
                                                    fontFamily:
                                                        'Hanken Grotesk',
                                                    fontSize: 16.0,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //booton login password
                                  Visibility(
                                    visible: !_isTextFieldVisible,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors
                                                  .grey, // Warna garis sekeliling
                                              width: 2.0, // Ketebalan garis
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Jika ingin border sudut melengkung
                                          ),
                                          child: IconButton(
                                              icon: Icon(Icons.arrow_back),
                                              onPressed: () {
                                                context.go('/choose-access');
                                              }),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _isButtonPassEnabled
                                                ? () {
                                                    _loginPass();
                                                  }
                                                : null,
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                                  if (states.contains(
                                                      WidgetState.disabled)) {
                                                    return Color(
                                                        0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                                  }
                                                  return Color(
                                                      0xFF07840B); // Warna saat tombol aktif
                                                },
                                              ),
                                              padding: WidgetStateProperty.all<
                                                  EdgeInsets>(
                                                EdgeInsets.symmetric(
                                                    vertical:
                                                        16.0), // Menyesuaikan padding agar tombol lebih tinggi
                                              ),
                                              minimumSize:
                                                  WidgetStateProperty.all<Size>(
                                                Size(double.infinity,
                                                    56), // Ukuran minimum tombol dengan tinggi 56
                                              ),
                                              shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Sama dengan border-radius: 8px;
                                                ),
                                              ),
                                              foregroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith<Color?>(
                                                (Set<WidgetState> states) {
                                                  if (states.contains(
                                                      WidgetState.disabled)) {
                                                    return Colors
                                                        .white; // Warna teks saat tombol dinonaktifkan
                                                  }
                                                  return Colors
                                                      .white; // Warna teks saat tombol aktif
                                                },
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(width: 10),
                                                Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 79, 77, 77),
                                                    fontFamily:
                                                        'Hanken Grotesk',
                                                    fontSize: 16.0,
                                                    fontStyle: FontStyle.normal,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showPopup)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.amber.withOpacity(0.95),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Download versi APK ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  html.window.open(
                                      "https://report-id.online/apk/download/visitorinduction_uat/",
                                      "_blank");
                                },
                                child: const Text("Download"),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _showPopup = false;
                                  });
                                  // Disarankan pakai state management atau setState global
                                  // tapi ini hanya demo, jadi tidak persist
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF07840B)), // Warna hijau
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
