import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:she_vi/services/api_service.dart';
// import 'package:app_shevi/screens/login2_screen.dart';
//import 'package:she_vi/screens/home/mainmenu_screen.dart';
import 'package:she_vi/screens/createnewpass_screen.dart';

class LoginScreen extends StatefulWidget {
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
  //bool _isTextVisible = false;

  final ApiService _apiService = ApiService();

  bool _isTextFieldVisible = true;
//  TextEditingController _usernameController = TextEditingController();

  void _login() async {
    String username = _usernameController.text;
    if (username.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      bool isLoginSuccessful = await _apiService.loginNik(username);
      setState(() {
        _isLoading = false;
      });

      if (isLoginSuccessful) {
        _isTextFieldVisible = !_isTextFieldVisible;
      } else {
        if (_apiService.lastResponseStatusCode == 400) {
          _showLoginError();
        } else if (_apiService.lastResponseStatusCode == 401) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewPass(employeeid: username),
            ),
          );
        } else {
          // Tampilkan error koneksi jika tidak ada respon yang valid
          _showConnectionError();
        }
      }
    } else {
      _showLoginError();
    }
  }

  void _changeEmployeeId() {
    _isTextFieldVisible = !_isTextFieldVisible;
  }

  void _loginPass() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool isLoginSuccessful =
            await _apiService.loginNikPass(username, password);
        setState(() {
          _isLoading = false;
        });

        if (isLoginSuccessful) {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => MainmenuScreen(employeeid: username),
          //   ),
          // );
          Navigator.pushNamed(
            context,
            '/main-menu',
            arguments:
                username, // Gantilah dengan variabel atau data yang relevan
          );
        } else {
          _showLoginPassError(
            errorMessage: 'Login gagal. Harap periksa kembali kredensial Anda.',
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Menampilkan error dari server atau default
        _showLoginPassError(errorMessage: e.toString());
      }
    } else {
      _showLoginPassError(
        errorMessage: 'Username dan password tidak boleh kosong.',
      );
    }
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

  void _showLoginPassError(
      {String errorMessage =
          'Username atau password yang Anda masukkan salah.'}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Gagal'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
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

  void _showConnectionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(
            'Tidak dapat terhubung ke server. Silakan periksa koneksi Anda.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkIfButtonShouldBeEnabled);
    _passwordController.addListener(_checkIfButtonPassBeEnabled);
  }

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      // Aktifkan tombol jika kedua field (nik) tidak kosong
      _isButtonEnabled = _usernameController.text.length >= 6;
    });
  }

  @override
  void _checkIfButtonPassBeEnabled() {
    setState(() {
      // Aktifkan tombol jika kedua field (pass) tidak kosong
      _isButtonPassEnabled = _passwordController.text.length >= 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;

    // Breakpoint responsivitas
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          return Center(
            child: Container(
              // height: maxHeight,
              // width: constraints.maxWidth,
              width: MediaQuery.of(context).size.shortestSide,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/BackgroundSedia.png',
                      fit: BoxFit.cover,
                    ),
                  ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    SizedBox(height: 16),
                                    Text(
                                      'Please provide your account details.',
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 117, 117,
                                            117), // Warna dari #757575
                                        fontFamily:
                                        'Hanken Grotesk', // Font-family
                                        fontSize: 16.0, // Ukuran font
                                        fontStyle:
                                        FontStyle.normal, // Font-style normal
                                        fontWeight: FontWeight
                                            .w400, // Berat font (400 = normal)
                                        height: 1.0, // Line-height (normal)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
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
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // TextField(
                                    //   controller: _usernameController,
                                    //   decoration: InputDecoration(
                                    //     hintText: 'Enter your employee id',
                                    //     prefixIcon: Icon(Icons.person),
                                    //     border: OutlineInputBorder(),
                                    //   ),
                                    // ),
                                    Visibility(
                                      visible: _isTextFieldVisible,
                                      child: TextField(
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter your employee id',
                                          prefixIcon: Icon(Icons.person),
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
                                          // Teks di sebelah kiri
                                          Text(
                                            _usernameController
                                                .text, // Menampilkan teks yang dimasukkan di TextField
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
                                            //onPressed: () {
                                            // Aksi yang ingin dijalankan ketika tombol ditekan
                                            //},
                                            style: ButtonStyle(
                                              padding: MaterialStateProperty.all<
                                                  EdgeInsets>(
                                                  EdgeInsets.symmetric(
                                                      vertical: 8, horizontal: 16)),
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(255, 248, 250,
                                                      248)), // Warna background
                                              shape: MaterialStateProperty.all<
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
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFF07840B)),
                                              textStyle: MaterialStateProperty.all<
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
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        decoration: InputDecoration(
                                          //labelText: 'Enter your password',
                                          hintText: 'Enter your password',
                                          prefixIcon: Container(
                                            padding: EdgeInsets.only(
                                                right:
                                                10), // Jarak antara garis dan teks
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.grey, // Warna garis
                                                  width: 1.0, // Ketebalan garis
                                                ),
                                              ),
                                            ),
                                            child: Icon(Icons.lock,
                                                color: const Color.fromARGB(255,
                                                    170, 171, 172)), // Ikon gembok
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
                                                // Navigasi kembali ke halaman sebelumnya
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // SizedBox(height: 30), // Gap between buttons
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed:
                                              _isButtonEnabled ? _login : null,
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
                                                          255,
                                                          79,
                                                          77,
                                                          77), // Warna dari #757575
                                                      fontFamily:
                                                      'Hanken Grotesk', // Font-family
                                                      fontSize: 16.0, // Ukuran font
                                                      fontStyle: FontStyle
                                                          .normal, // Font-style normal
                                                      fontWeight: FontWeight
                                                          .w400, // Berat font (400 = normal)
                                                      height:
                                                      1.0, // Line-height (normal)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color?>(
                                                      (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState.disabled)) {
                                                      return Color(
                                                          0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                                    }
                                                    return Color(
                                                        0xFF07840B); // Warna saat tombol aktif
                                                  },
                                                ),
                                                padding: MaterialStateProperty.all<
                                                    EdgeInsets>(
                                                  EdgeInsets.symmetric(
                                                      vertical:
                                                      16.0), // Menyesuaikan padding agar tombol lebih tinggi
                                                ),
                                                minimumSize:
                                                MaterialStateProperty.all<Size>(
                                                  Size(double.infinity,
                                                      56), // Ukuran minimum tombol dengan tinggi 56
                                                ),
                                                shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                        8.0), // Sama dengan border-radius: 8px;
                                                  ),
                                                ),
                                                foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color?>(
                                                      (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState.disabled)) {
                                                      return Colors.white;
                                                    }
                                                    return Colors.white;
                                                  },
                                                ),
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
                                                // Navigasi kembali ke halaman sebelumnya
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // SizedBox(height: 30), // Gap between buttons
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isButtonPassEnabled
                                                  ? () {
                                                _loginPass();
                                              }
                                                  : null,
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
                                                      fontFamily: 'Hanken Grotesk',
                                                      fontSize: 16.0,
                                                      fontStyle: FontStyle.normal,
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color?>(
                                                      (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState.disabled)) {
                                                      return Color(
                                                          0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                                    }
                                                    return Color(
                                                        0xFF07840B); // Warna saat tombol aktif
                                                  },
                                                ),
                                                padding: MaterialStateProperty.all<
                                                    EdgeInsets>(
                                                  EdgeInsets.symmetric(
                                                      vertical:
                                                      16.0), // Menyesuaikan padding agar tombol lebih tinggi
                                                ),
                                                minimumSize:
                                                MaterialStateProperty.all<Size>(
                                                  Size(double.infinity,
                                                      56), // Ukuran minimum tombol dengan tinggi 56
                                                ),
                                                shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                        8.0), // Sama dengan border-radius: 8px;
                                                  ),
                                                ),
                                                foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color?>(
                                                      (Set<MaterialState> states) {
                                                    if (states.contains(
                                                        MaterialState.disabled)) {
                                                      return Colors
                                                          .white; // Warna teks saat tombol dinonaktifkan
                                                    }
                                                    return Colors
                                                        .white; // Warna teks saat tombol aktif
                                                  },
                                                ),
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

                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Column(
                  //         // mainAxisAlignment: MainAxisAlignment.center,
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: <Widget>[
                  //           Padding(
                  //             padding: const EdgeInsets.only(
                  //               top: 200.0,
                  //               left: 24.0,
                  //               right: 15.0,
                  //             ),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment
                  //                   .start, // Mengatur posisi teks ke kiri
                  //               children: [
                  //                 Text(
                  //                   'Welcome to',
                  //                   style: TextStyle(
                  //                     fontSize: 40.0,
                  //                     color: Color.fromARGB(255, 7, 132, 11),
                  //                     fontFamily: 'Hanken Grotesk',
                  //                     fontWeight: FontWeight.w900,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   'SEDIA Apps',
                  //                   style: TextStyle(
                  //                     fontSize: 40.0,
                  //                     color: Color.fromARGB(255, 7, 132, 11),
                  //                     fontFamily: 'Hanken Grotesk',
                  //                     fontWeight: FontWeight.w900,
                  //                     height: 0.9,
                  //                   ),
                  //                 ),
                  //                 SizedBox(height: 16), // Jarak antara dua teks
                  //
                  //                 // Jarak antara dua teks
                  //                 Text(
                  //                   'Please provide your account details.',
                  //                   style: TextStyle(
                  //                     color: const Color.fromARGB(255, 117, 117,
                  //                         117), // Warna dari #757575
                  //                     fontFamily:
                  //                         'Hanken Grotesk', // Font-family
                  //                     fontSize: 16.0, // Ukuran font
                  //                     fontStyle:
                  //                         FontStyle.normal, // Font-style normal
                  //                     fontWeight: FontWeight
                  //                         .w400, // Berat font (400 = normal)
                  //                     height: 1.0, // Line-height (normal)
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  //
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
    );
  }
}
