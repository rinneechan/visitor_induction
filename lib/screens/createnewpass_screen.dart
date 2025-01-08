import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:she_vi/screens/login/login_screen.dart';
import 'package:she_vi/screens/login/_OKcreatenewpass_screen.dart';

class CreateNewPass extends StatefulWidget {
  final String employeeid;
  const CreateNewPass({Key? key, required this.employeeid}) : super(key: key);

  @override
  _CreateNewPassState createState() => _CreateNewPassState();
}

class _CreateNewPassState extends State<CreateNewPass> {
  final _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isPasswordVisible = false;
  bool _isObscured = true;
  bool _isObscuredRe = true;

  void _login() {
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/BackgroundSedia.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.40),
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
          SizedBox(height: 10),
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
                        SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Memposisikan teks di tengah
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navigasi ke halaman CreateNewPass
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OkCreateNewPass()),
                                );
                              },
                              child: Text(
                                'Create New Password',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 79, 77, 77),
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Memposisikan teks di tengah
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navigasi ke halaman CreateNewPass
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OkCreateNewPass()),
                                );
                              },
                              child: Text(
                                'Your registration is almost done.',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 79, 77, 77),
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Memposisikan teks di tengah
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Navigasi ke halaman CreateNewPass
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OkCreateNewPass()),
                                );
                              },
                              child: Text(
                                'Please set up a password to secure your account.',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 79, 77, 77),
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                        Text(
                          'Password',
                          style: TextStyle(
                            color: Color(0xFF343434),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0, // Ukuran font
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 10),

                        TextField(
                          obscureText:
                              _isObscured, // Menyembunyikan atau menampilkan password
                          decoration: InputDecoration(
                            labelText: 'Enter Your Password',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility, // Ikon mata
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured =
                                      !_isObscured; // Mengubah status visibility
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 8,
                                    color: Color(0xFFD1D1D1)), // Bullet point
                                SizedBox(
                                    width: 8), // Jarak antara bullet dan teks
                                Text(
                                  'At least 8 characters',
                                  style: TextStyle(
                                    color: Color(0xFF343434),
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 14.0, // Ukuran font
                                    fontWeight: FontWeight.normal,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Jarak antar item
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 8,
                                    color: Color(0xFFD1D1D1)), // Bullet point
                                SizedBox(
                                    width: 8), // Jarak antara bullet dan teks
                                Text(
                                  'Mix of upper & lowercase',
                                  style: TextStyle(
                                    color: Color(0xFF343434),
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 14.0, // Ukuran font
                                    fontWeight: FontWeight.normal,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 8,
                                    color: Color(0xFFD1D1D1)), // Bullet point
                                SizedBox(
                                    width: 8), // Jarak antara bullet dan teks
                                Text(
                                  'Include a number and symbol',
                                  style: TextStyle(
                                    color: Color(0xFF343434),
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 14.0, // Ukuran font
                                    fontWeight: FontWeight.normal,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        Text(
                          'Re-type Password',
                          style: TextStyle(
                            color: Color(0xFF343434),
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 16.0, // Ukuran font
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),

                        SizedBox(height: 8),
                        TextField(
                          obscureText: _isObscuredRe,
                          decoration: InputDecoration(
                            labelText: 'Re-enter your password',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscuredRe
                                    ? Icons.visibility_off
                                    : Icons.visibility, // Ikon mata
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscuredRe =
                                      !_isObscuredRe; // Mengubah status visibility
                                });
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 24), // Jarak sebelum tombol

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 30), // Gap between buttons
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigasi kembali ke halaman sebelumnya
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Sama dengan justify-content: center;
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Sama dengan align-items: center;
                                  children: [
                                    SizedBox(
                                        width: 10), // Sama dengan gap: 16px
                                    Text(
                                      'Set Password',
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 79, 77,
                                            77), // Warna dari #757575
                                        fontFamily:
                                            'Hanken Grotesk', // Font-family
                                        fontSize: 16.0, // Ukuran font
                                        fontStyle: FontStyle
                                            .normal, // Font-style normal
                                        fontWeight: FontWeight
                                            .w400, // Berat font (400 = normal)
                                        height: 1.0, // Line-height (normal)
                                      ),
                                    ),
                                  ],
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Color(
                                            0xFFA4A4A4); // Warna saat tombol dinonaktifkan
                                      }
                                      return Color(
                                          0xFF07840B); // Warna saat tombol aktif
                                    },
                                  ),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                        vertical:
                                            16.0), // Menyesuaikan padding agar tombol lebih tinggi
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Sama dengan border-radius: 8px;
                                    ),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
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
                      ],
                    ),
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
